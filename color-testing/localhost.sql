-- phpMyAdmin SQL Dump
-- version 3.2.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: May 15, 2011 at 04:18 PM
-- Server version: 5.1.37
-- PHP Version: 5.2.11

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `color-rec`
--
CREATE DATABASE `color-rec` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `color-rec`;

-- --------------------------------------------------------

--
-- Table structure for table `colors`
--

CREATE TABLE `colors` (
  `color_id` int(3) NOT NULL AUTO_INCREMENT,
  `hex_value` varchar(6) DEFAULT NULL,
  `color_category` varchar(100) DEFAULT NULL,
  `color_item` varchar(100) DEFAULT NULL,
  `source` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`color_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=7 ;

--
-- Dumping data for table `colors`
--

INSERT INTO `colors` VALUES(1, '1C86EE', 'category1', 'item1', 'auto');
INSERT INTO `colors` VALUES(2, 'CD0000', 'category1', 'item1', 'expert');
INSERT INTO `colors` VALUES(3, '228B22', 'category2', 'item1', 'auto');
INSERT INTO `colors` VALUES(4, '6B6B6B', 'category1', 'item2', 'auto');
INSERT INTO `colors` VALUES(5, '20B2AA', 'category1', 'item2', 'expert');
INSERT INTO `colors` VALUES(6, '7D26CD', 'category2', 'item1', 'expert');

-- --------------------------------------------------------

--
-- Table structure for table `likability`
--

CREATE TABLE `likability` (
  `color_id` int(3) NOT NULL,
  `worker_id` varchar(50) DEFAULT NULL,
  `rating` int(1) DEFAULT NULL,
  KEY `color_id` (`color_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `likability`
--

INSERT INTO `likability` VALUES(1, 'test', 7);
INSERT INTO `likability` VALUES(2, 'test', 5);

-- --------------------------------------------------------

--
-- Table structure for table `relevance`
--

CREATE TABLE `relevance` (
  `prompt_category` varchar(100) DEFAULT NULL,
  `prompt_item` varchar(100) DEFAULT NULL,
  `worker_id` varchar(50) DEFAULT NULL,
  `color_id` int(3) NOT NULL,
  KEY `color_id` (`color_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `relevance`
--

INSERT INTO `relevance` VALUES('category1', 'item1', 'test', 2);
INSERT INTO `relevance` VALUES('category1', 'item2', 'test', 6);
INSERT INTO `relevance` VALUES('category2', 'item1', 'test', 1);
INSERT INTO `relevance` VALUES('category1', 'item2', 'test2', 5);
INSERT INTO `relevance` VALUES('category1', 'item1', 'test2', 2);
INSERT INTO `relevance` VALUES('category2', 'item1', 'test2', 6);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `likability`
--
ALTER TABLE `likability`
  ADD CONSTRAINT `likability_ibfk_1` FOREIGN KEY (`color_id`) REFERENCES `colors` (`color_id`);

--
-- Constraints for table `relevance`
--
ALTER TABLE `relevance`
  ADD CONSTRAINT `relevance_ibfk_1` FOREIGN KEY (`color_id`) REFERENCES `colors` (`color_id`);
