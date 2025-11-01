-- Knowledge Base Database Schema
-- Run this in phpMyAdmin or MySQL command line to create all required tables

USE knowledge_base;

-- User table
CREATE TABLE IF NOT EXISTS `user` (
  `user_id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `display_name` VARCHAR(255) NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Document table
CREATE TABLE IF NOT EXISTS `document` (
  `document_id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `title` VARCHAR(500) NOT NULL,
  `description` TEXT,
  `file_path` VARCHAR(1000),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Comments table
CREATE TABLE IF NOT EXISTS `comments` (
  `comment_id` INT AUTO_INCREMENT PRIMARY KEY,
  `document_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `body` TEXT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`document_id`) REFERENCES `document`(`document_id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `user`(`user_id`) ON DELETE CASCADE,
  INDEX `idx_document_id` (`document_id`),
  INDEX `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Tags table
CREATE TABLE IF NOT EXISTS `tags` (
  `tag_id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL UNIQUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Document-Tags junction table
CREATE TABLE IF NOT EXISTS `document_tags` (
  `document_id` INT NOT NULL,
  `tag_id` INT NOT NULL,
  PRIMARY KEY (`document_id`, `tag_id`),
  FOREIGN KEY (`document_id`) REFERENCES `document`(`document_id`) ON DELETE CASCADE,
  FOREIGN KEY (`tag_id`) REFERENCES `tags`(`tag_id`) ON DELETE CASCADE,
  INDEX `idx_document_id` (`document_id`),
  INDEX `idx_tag_id` (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

