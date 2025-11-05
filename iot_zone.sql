-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 26, 2025 at 07:33 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `iot_zone`
--

-- --------------------------------------------------------

--
-- Table structure for table `asset`
--

CREATE TABLE `asset` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `asset_name` varchar(60) NOT NULL,
  `description` varchar(100) NOT NULL,
  `type` varchar(60) NOT NULL,
  `status` int(1) NOT NULL COMMENT '1=available, 2=disabled, 3=pending, 4=borrowed',
  `img` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `asset`
--

INSERT INTO `asset` (`id`, `asset_name`, `description`, `type`, `status`, `img`) VALUES
(1, 'Capacitor', 'Capacitor\'s description', 'Component', 1, 'Capacitor.png'),
(2, 'Multimeter', 'Multimeter\'s description', 'Measurement', 2, 'Multimeter.png'),
(3, 'Resistor', 'Resistor\'s description', 'Component', 3, 'Resistor.png'),
(4, 'SN74LS32N', 'SN74LS32N\'s description', 'Logic', 4, 'SN74LS32N.png'),
(5, 'Transistor', 'Transistor\'s description', 'Component', 1, 'Transistor.png');

-- --------------------------------------------------------

--
-- Table structure for table `history`
--

CREATE TABLE `history` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `asset_id` tinyint(3) UNSIGNED NOT NULL,
  `borrower_id` tinyint(3) UNSIGNED NOT NULL,
  `approver_id` tinyint(3) UNSIGNED DEFAULT NULL,
  `reveiver_id` tinyint(3) UNSIGNED DEFAULT NULL,
  `status` tinyint(1) UNSIGNED NOT NULL COMMENT '1=pending, 2=approved, 3=rejected, 4=returned',
  `borrow_date` datetime NOT NULL,
  `return_date` datetime NOT NULL,
  `reason` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` tinyint(3) UNSIGNED NOT NULL,
  `username` varchar(30) NOT NULL,
  `password` varchar(60) NOT NULL,
  `name` varchar(60) NOT NULL,
  `phone` varchar(10) NOT NULL,
  `email` varchar(100) NOT NULL,
  `img` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `username`, `password`, `name`, `phone`, `email`, `img`) VALUES
(1, 'Student1', '$2b$10$Y3oek21e9XKKZROIfWJdF.vN3esFxb3RtdgI.Rl32.VpcpRyIRftq', 'Pongsapat P.', '09xxxxxxxx', 'pongsapat@gmail.com', ''),
(2, 'Staff1', '$2b$10$fnA2QIekzvnKOml9LD99p.eNHHe7JSJKJBdOKEMJsVSAly.8GIRH6', 'John Doe', '09xxxxxxxx', 'john_doe@gmail.com', ''),
(3, 'Lender1', '$2b$10$pGG.dEEAD0Pdw8ZLH6.Ek.5JAmHfV4IMOlQLi0./s88FheYmTyOJq', 'Prof. John Smith', '09xxxxxxxx', 'j_smith@gmail.com', '');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `asset`
--
ALTER TABLE `asset`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `history`
--
ALTER TABLE `history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_asset_id` (`asset_id`),
  ADD KEY `fk_borrower_id` (`borrower_id`),
  ADD KEY `fk_approver_id` (`approver_id`),
  ADD KEY `fk_receiver_id` (`reveiver_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `asset`
--
ALTER TABLE `asset`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `history`
--
ALTER TABLE `history`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` tinyint(3) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `history`
--
ALTER TABLE `history`
  ADD CONSTRAINT `fk_approver_id` FOREIGN KEY (`approver_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `fk_asset_id` FOREIGN KEY (`asset_id`) REFERENCES `asset` (`id`),
  ADD CONSTRAINT `fk_borrower_id` FOREIGN KEY (`borrower_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `fk_receiver_id` FOREIGN KEY (`reveiver_id`) REFERENCES `user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
