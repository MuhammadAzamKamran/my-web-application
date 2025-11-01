import mysql from 'mysql2/promise';

export async function createPool() {
  const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    namedPlaceholders: true,
    connectTimeout: 10000, // 10 seconds
    acquireTimeout: 10000, // 10 seconds
    timeout: 10000, // 10 seconds
    enableKeepAlive: true,
    keepAliveInitialDelay: 0
  });
  return pool;
}