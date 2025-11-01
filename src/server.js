import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import pino from 'pino';
import multer from 'multer';
import fs from 'fs';
import path from 'path';
import session from 'express-session';
import passport from 'passport';
import { Strategy as GoogleStrategy } from 'passport-google-oauth20';
import { body, param, validationResult } from 'express-validator';
import { createPool } from './db.js';

const app = express();
const logger = pino({ level: 'info' });
const poolPromise = createPool();

// Session configuration
app.use(session({
  secret: process.env.SESSION_SECRET || 'your-secret-key-change-this-in-production',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: false, // Set to true if using HTTPS
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// Passport initialization
app.use(passport.initialize());
app.use(passport.session());

// Passport Google OAuth Strategy (only if credentials are provided)
if (process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET) {
  passport.use(new GoogleStrategy({
    clientID: process.env.GOOGLE_CLIENT_ID,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    callbackURL: 'http://localhost:4000/auth/google/callback'
  }, async (accessToken, refreshToken, profile, done) => {
    try {
      const pool = await poolPromise;
      const email = profile.emails[0].value;
      const displayName = profile.displayName;
      
      // Check if user exists
      const [existingUser] = await pool.query(
        'SELECT user_id, email, display_name FROM user WHERE email = ? LIMIT 1',
        [email]
      );

      let userId;
      if (existingUser.length) {
        userId = existingUser[0].user_id;
      } else {
        // Create new user
        const [insUser] = await pool.query(
          'INSERT INTO user (email, display_name) VALUES (?, ?)',
          [email, displayName]
        );
        userId = insUser.insertId;
      }

      const user = {
        userId,
        email,
        displayName
      };

      return done(null, user);
    } catch (err) {
      return done(err, null);
    }
  }));
  logger.info('Google OAuth configured');
} else {
  logger.info('Google OAuth not configured - using local authentication only');
}

// Passport serialization
passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user);
});

app.use(cors({
  origin: 'http://localhost:4000',
  credentials: true
}));
app.use(express.json({ limit: '2mb' }));
app.use(express.static('.'));

// Ensure upload dir exists
const uploadDir = process.env.UPLOAD_DIR || 'uploads';
fs.mkdirSync(uploadDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, uploadDir),
  filename: (_req, file, cb) => {
    const safeName = file.originalname.replace(/[^\w.\-]+/g, '_');
    const ts = Date.now();
    cb(null, `${ts}-${safeName}`);
  }
});
const upload = multer({ storage });

// Helpers
function handleValidation(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
}

// Authentication Routes

// GET /auth/google - Initiate Google OAuth
app.get('/auth/google', (req, res, next) => {
  if (!process.env.GOOGLE_CLIENT_ID || !process.env.GOOGLE_CLIENT_SECRET) {
    return res.redirect('/login.html?error=google_not_configured');
  }
  passport.authenticate('google', { scope: ['profile', 'email'] })(req, res, next);
});

// GET /auth/google/callback - Google OAuth callback
app.get('/auth/google/callback', (req, res, next) => {
  if (!process.env.GOOGLE_CLIENT_ID || !process.env.GOOGLE_CLIENT_SECRET) {
    return res.redirect('/login.html?error=google_not_configured');
  }
  passport.authenticate('google', { failureRedirect: '/login.html?error=auth_failed' })(req, res, next);
}, (req, res) => {
  // Successful authentication
  res.redirect('/upload.html');
});

// POST /api/auth/local - Local email/name authentication
app.post('/api/auth/local', async (req, res) => {
  const { email, displayName, isSignUp } = req.body;

  if (!email || !displayName) {
    return res.status(400).json({ error: 'Email and display name are required' });
  }

  try {
    const pool = await poolPromise;
    
    if (isSignUp) {
      // Check if user already exists
      const [existingUser] = await pool.query(
        'SELECT user_id FROM user WHERE email = ? LIMIT 1',
        [email]
      );

      if (existingUser.length) {
        return res.status(409).json({ error: 'User with this email already exists' });
      }

      // Create new user
      const [insUser] = await pool.query(
        'INSERT INTO user (email, display_name) VALUES (?, ?)',
        [email, displayName]
      );

      const user = {
        userId: insUser.insertId,
        email,
        displayName
      };

      return res.json({ 
        success: true, 
        user,
        token: 'local-auth-token'
      });
    } else {
      // Sign in - find existing user
      const [users] = await pool.query(
        'SELECT user_id, email, display_name FROM user WHERE email = ? LIMIT 1',
        [email]
      );

      if (!users.length) {
        return res.status(404).json({ error: 'User not found' });
      }

      const user = {
        userId: users[0].user_id,
        email: users[0].email,
        displayName: users[0].display_name
      };

      return res.json({ 
        success: true, 
        user,
        token: 'local-auth-token'
      });
    }
  } catch (err) {
    logger.error(err);
    res.status(500).json({ error: 'Authentication failed', details: err.message });
  }
});

// GET /api/auth/status - Check authentication status
app.get('/api/auth/status', (req, res) => {
  if (req.isAuthenticated && req.isAuthenticated()) {
    res.json({ authenticated: true, user: req.user });
  } else {
    res.json({ authenticated: false });
  }
});

// POST /api/auth/logout - Logout
app.post('/api/auth/logout', (req, res) => {
  req.logout((err) => {
    if (err) {
      return res.status(500).json({ error: 'Logout failed' });
    }
    req.session.destroy((err) => {
      if (err) {
        return res.status(500).json({ error: 'Session destruction failed' });
      }
      res.json({ success: true, message: 'Logged out successfully' });
    });
  });
});

// POST /api/documents/metadata
// Creates user if needed, inserts document, comments, tags within a transaction.
app.post(
  '/api/documents/metadata',
  [
    body('user.email').isEmail(),
    body('user.displayName').isString().isLength({ min: 1 }),
    body('document.title').isString().isLength({ min: 1 }),
    body('document.description').optional().isString(),
    body('comments').optional().isArray(),
    body('comments.*.body').optional().isString().isLength({ min: 1 }),
    body('tags').optional().isArray(),
    body('tags.*').optional().isString().isLength({ min: 1 })
  ],
  async (req, res) => {
    const invalid = handleValidation(req, res);
    if (invalid) return;

    const {
      user: userPayload,
      document: docPayload,
      comments = [],
      tags = []
    } = req.body;

    const pool = await poolPromise;
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // Upsert user by email
      const [existingUser] = await conn.query(
        'SELECT user_id FROM user WHERE email = ? LIMIT 1',
        [userPayload.email]
      );
      let userId;
      if (existingUser.length) {
        userId = existingUser[0].user_id;
      } else {
        const [insUser] = await conn.query(
          'INSERT INTO user (email, display_name) VALUES (?, ?)',
          [userPayload.email, userPayload.displayName]
        );
        userId = insUser.insertId;
      }

      // Insert document
      const [insDoc] = await conn.query(
        'INSERT INTO document (user_id, title, description) VALUES (?, ?, ?)',
        [userId, docPayload.title, docPayload.description || null]
      );
      const documentId = insDoc.insertId;

      // Insert comments
      for (const c of comments) {
        await conn.query(
          'INSERT INTO comments (document_id, user_id, body) VALUES (?, ?, ?)',
          [documentId, userId, c.body]
        );
      }

      // Upsert tags and link
      for (const name of tags) {
        const trimmed = name.trim();
        if (!trimmed) continue;
        let tagId;
        try {
          const [insTag] = await conn.query(
            'INSERT INTO tags (name) VALUES (?)',
            [trimmed]
          );
          tagId = insTag.insertId;
        } catch (e) {
          // duplicate -> fetch existing
          const [row] = await conn.query(
            'SELECT tag_id FROM tags WHERE name = ? LIMIT 1',
            [trimmed]
          );
          if (!row.length) throw e;
          tagId = row[0].tag_id;
        }
        await conn.query(
          'INSERT IGNORE INTO document_tags (document_id, tag_id) VALUES (?, ?)',
          [documentId, tagId]
        );
      }

      await conn.commit();
      res.status(201).json({ documentId, userId });
    } catch (err) {
      await conn.rollback();
      logger.error(err);
      res.status(500).json({ error: 'Failed to save metadata', details: err.message });
    } finally {
      conn.release();
    }
  }
);

// POST /api/documents/:id/file
// Uploads and associates a file with an existing document.
app.post(
  '/api/documents/:id/file',
  [param('id').isInt()],
  upload.single('file'),
  async (req, res) => {
    const invalid = handleValidation(req, res);
    if (invalid) return;
    if (!req.file) {
      return res.status(400).json({ error: 'file is required' });
    }

    const documentId = Number(req.params.id);
    const relPath = path.join(uploadDir, req.file.filename);

    try {
      const pool = await poolPromise;
      const [result] = await pool.query(
        'UPDATE document SET file_path = ? WHERE document_id = ?',
        [relPath, documentId]
      );
      if (result.affectedRows === 0) {
        // clean up orphaned file
        fs.unlink(req.file.path, () => {});
        return res.status(404).json({ error: 'Document not found' });
      }
      res.status(200).json({ documentId, filePath: relPath });
    } catch (err) {
      logger.error(err);
      fs.unlink(req.file.path, () => {});
      res.status(500).json({ error: 'Failed to attach file', details: err.message });
    }
  }
);

// GET /api/documents
// Retrieves all documents with their tags
app.get('/api/documents', async (req, res) => {
  try {
    const pool = await poolPromise;
    const [documents] = await pool.query(`
      SELECT 
        d.document_id,
        d.title,
        d.description,
        d.file_path,
        d.created_at,
        u.display_name as user_name,
        u.email as user_email
      FROM document d
      JOIN user u ON d.user_id = u.user_id
      ORDER BY d.created_at DESC
    `);

    // Get tags for each document
    for (const doc of documents) {
      const [tags] = await pool.query(`
        SELECT t.name
        FROM tags t
        JOIN document_tags dt ON t.tag_id = dt.tag_id
        WHERE dt.document_id = ?
      `, [doc.document_id]);
      doc.tags = tags;
    }

    res.json(documents);
  } catch (err) {
    logger.error(err);
    res.status(500).json({ error: 'Failed to retrieve documents', details: err.message });
  }
});

const port = Number(process.env.PORT || 4000);
app.listen(port, () => {
  logger.info(`API listening on http://localhost:${port}`);
});