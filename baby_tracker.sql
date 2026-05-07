-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 06 مايو 2026 الساعة 22:18
-- إصدار الخادم: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `baby_tracker1`
--

DELIMITER $$
--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `get_doctor_appointments_count` (`doctor_id_param` INT, `appointment_date_param` DATE) RETURNS INT(11) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE count_result INT;
    
    SELECT COUNT(*) INTO count_result
    FROM appointments
    WHERE doctor_id = doctor_id_param
    AND DATE(appointment_date) = appointment_date_param
    AND appointment_status NOT IN ('cancelled', 'no-show');
    
    RETURN count_result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_expired_prescriptions_count` (`child_id_param` INT) RETURNS INT(11) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE result INT;
    SELECT COUNT(*) INTO result
    FROM prescriptions
    WHERE child_id = child_id_param
    AND status = 'active'
    AND expiry_date < CURDATE();
    RETURN result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_expiring_prescriptions_count` (`child_id_param` INT, `days_before` INT) RETURNS INT(11) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE result INT;
    SELECT COUNT(*) INTO result
    FROM prescriptions
    WHERE child_id = child_id_param
    AND status = 'active'
    AND expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL days_before DAY);
    RETURN result;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `is_doctor_available_at` (`doctor_id_param` INT, `check_datetime` DATETIME) RETURNS TINYINT(1) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE day_name VARCHAR(20);
    DECLARE check_time TIME;
    DECLARE schedule_count INT;
    DECLARE unavailable_count INT;
    DECLARE booked_count INT;
    
    SET day_name = DATE_FORMAT(check_datetime, '%W');
    SET check_time = TIME(check_datetime);
    
    
    SELECT COUNT(*) INTO schedule_count 
    FROM doctor_schedules 
    WHERE doctor_id = doctor_id_param 
    AND day_of_week = day_name 
    AND is_available = TRUE
    AND check_time >= start_time 
    AND check_time < end_time;
    
    IF schedule_count = 0 THEN
        RETURN FALSE;
    END IF;
    
    
    SELECT COUNT(*) INTO unavailable_count 
    FROM doctor_unavailable_slots 
    WHERE doctor_id = doctor_id_param 
    AND check_datetime >= start_date 
    AND check_datetime < end_date;
    
    IF unavailable_count > 0 THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- بنية الجدول `admin_logs`
--

CREATE TABLE `admin_logs` (
  `id` int(11) NOT NULL,
  `admin_id` int(11) NOT NULL,
  `action` varchar(255) NOT NULL,
  `target_type` enum('user','child','vaccine','note','setting') NOT NULL,
  `target_id` int(11) DEFAULT NULL,
  `old_value` text DEFAULT NULL,
  `new_value` text DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `admin_logs`
--

INSERT INTO `admin_logs` (`id`, `admin_id`, `action`, `target_type`, `target_id`, `old_value`, `new_value`, `ip_address`, `created_at`) VALUES
(1, 1, 'إنشاء نسخة احتياطية', '', NULL, NULL, NULL, '::1', '2026-02-25 11:42:53'),
(2, 1, 'إنشاء نسخة احتياطية', '', NULL, NULL, NULL, '::1', '2026-02-25 11:42:56'),
(3, 1, 'إنشاء نسخة احتياطية', '', NULL, NULL, NULL, '::1', '2026-02-25 11:43:17'),
(4, 1, 'التحقق من نماذج AI', '', NULL, NULL, NULL, '::1', '2026-02-25 11:45:14'),
(5, 1, 'التحقق من نماذج AI', '', NULL, NULL, NULL, '::1', '2026-02-25 11:45:16'),
(6, 1, 'التحقق من نماذج AI', '', NULL, NULL, NULL, '::1', '2026-02-25 11:50:49'),
(7, 1, 'التحقق من نماذج AI', '', NULL, NULL, NULL, '::1', '2026-02-25 11:50:51'),
(8, 1, 'إضافة أب/أم جديد', '', 10, NULL, NULL, '::1', '2026-02-25 12:25:50'),
(9, 1, 'إضافة مستخدم جديد', '', 11, NULL, NULL, '::1', '2026-03-03 08:39:16'),
(10, 1, 'حذف مستخدم', 'user', 11, NULL, NULL, '::1', '2026-03-03 08:40:04'),
(11, 1, 'تعديل حالة تطعيم', 'vaccine', 5, NULL, NULL, '::1', '2026-03-03 09:22:02'),
(12, 1, 'التحقق من نماذج AI', '', NULL, NULL, NULL, '::1', '2026-03-03 09:22:22'),
(13, 1, 'تمكين نموذج AI', '', NULL, NULL, NULL, '::1', '2026-03-03 09:22:25'),
(14, 1, 'التحقق من نماذج AI', '', NULL, NULL, NULL, '::1', '2026-03-03 09:22:25'),
(15, 1, 'تمكين نموذج AI', '', NULL, NULL, NULL, '::1', '2026-03-03 09:22:29'),
(16, 1, 'التحقق من نماذج AI', '', NULL, NULL, NULL, '::1', '2026-03-03 09:22:29'),
(17, 1, 'تمكين نموذج AI', '', NULL, NULL, NULL, '::1', '2026-03-03 09:22:32'),
(18, 1, 'التحقق من نماذج AI', '', NULL, NULL, NULL, '::1', '2026-03-03 09:22:32'),
(19, 1, 'تحديث إعدادات النظام', '', NULL, NULL, NULL, '::1', '2026-03-03 09:23:01'),
(20, 1, 'إنشاء نسخة احتياطية', '', NULL, NULL, NULL, '::1', '2026-03-03 09:23:12'),
(21, 1, 'حذف نسخة احتياطية', '', NULL, NULL, NULL, '::1', '2026-03-03 10:02:53'),
(22, 1, 'إضافة أب/أم جديد', '', 12, NULL, NULL, '::1', '2026-03-09 09:12:16'),
(23, 1, 'تعديل بيانات أب/أم', '', 12, NULL, NULL, '::1', '2026-03-09 09:12:37'),
(24, 1, 'حذف أب/أم', '', 12, NULL, NULL, '::1', '2026-03-09 09:12:46'),
(25, 1, 'إضافة مستخدم جديد', '', 13, NULL, NULL, '::1', '2026-03-09 09:13:03'),
(26, 1, 'حذف مستخدم', 'user', 13, NULL, NULL, '::1', '2026-03-09 09:13:17'),
(27, 1, 'إضافة مستخدم جديد', '', 14, NULL, NULL, '::1', '2026-03-09 09:13:27'),
(28, 1, 'حذف مستخدم', 'user', 14, NULL, NULL, '::1', '2026-03-09 09:13:38'),
(29, 1, 'إضافة طفل', 'child', 10, NULL, NULL, '::1', '2026-03-09 09:13:51'),
(30, 1, 'تعديل ملف طفل', 'child', 10, NULL, NULL, '::1', '2026-03-09 09:14:06'),
(31, 1, 'تعديل ملف طفل', 'child', 10, NULL, NULL, '::1', '2026-03-09 09:14:18'),
(32, 1, 'تعديل ملف طفل', 'child', 10, NULL, NULL, '::1', '2026-03-09 09:14:27'),
(33, 1, 'تعديل ملف طفل', 'child', 10, NULL, NULL, '::1', '2026-03-09 09:20:37'),
(34, 1, 'أرشفة ملف طفل', 'child', 10, NULL, NULL, '::1', '2026-03-13 11:30:04'),
(35, 1, 'حذف سجل تطعيم', 'vaccine', 60, NULL, NULL, '::1', '2026-04-30 08:43:14'),
(36, 1, 'حذف سجل تطعيم', 'vaccine', 48, NULL, NULL, '::1', '2026-04-30 08:43:17'),
(37, 1, 'حذف سجل تطعيم', 'vaccine', 59, NULL, NULL, '::1', '2026-04-30 08:43:21'),
(38, 1, 'حذف سجل تطعيم', 'vaccine', 58, NULL, NULL, '::1', '2026-04-30 08:48:23'),
(39, 1, 'حذف سجل تطعيم', 'vaccine', 57, NULL, NULL, '::1', '2026-04-30 08:48:27');

-- --------------------------------------------------------

--
-- بنية الجدول `age_group_medication_lists`
--

CREATE TABLE `age_group_medication_lists` (
  `id` int(11) NOT NULL,
  `age_min_months` int(11) NOT NULL,
  `age_max_months` int(11) NOT NULL,
  `allowed_medications` text NOT NULL,
  `restricted_medications` text NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `age_group_medication_lists`
--

INSERT INTO `age_group_medication_lists` (`id`, `age_min_months`, `age_max_months`, `allowed_medications`, `restricted_medications`, `notes`, `created_at`, `updated_at`) VALUES
(1, 6, 8, 'Natus et aute laudan', 'Minus ea dolor aut e', 'Enim ea est pariatu', '2026-03-31 10:05:23', '2026-03-31 10:05:23'),
(6, 0, 10, 'Ut hic aute quo quas', 'Impedit nesciunt i', 'Enim ea est pariatu', '2026-04-01 06:27:20', '2026-04-01 06:27:20');

-- --------------------------------------------------------

--
-- بنية الجدول `ai_test_cases`
--

CREATE TABLE `ai_test_cases` (
  `id` int(11) NOT NULL,
  `model_type` varchar(100) NOT NULL,
  `input_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`input_data`)),
  `expected_output` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`expected_output`)),
  `actual_output` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`actual_output`)),
  `accuracy` float DEFAULT NULL,
  `status` enum('pending','passed','failed') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `appointments`
--

CREATE TABLE `appointments` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `appointment_date` datetime NOT NULL,
  `appointment_type` enum('check-up','follow-up','vaccination','consultation','emergency','emergency_call') DEFAULT 'check-up',
  `appointment_status` enum('scheduled','confirmed','completed','cancelled','no-show','rescheduled') DEFAULT 'scheduled',
  `reason_for_visit` text DEFAULT NULL,
  `diagnosis` longtext DEFAULT NULL,
  `treatment` longtext DEFAULT NULL,
  `notes` longtext DEFAULT NULL,
  `confirmation_status` enum('pending','confirmed','rejected') DEFAULT 'pending',
  `confirmation_date` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `appointments`
--

INSERT INTO `appointments` (`id`, `child_id`, `doctor_id`, `parent_id`, `appointment_date`, `appointment_type`, `appointment_status`, `reason_for_visit`, `diagnosis`, `treatment`, `notes`, `confirmation_status`, `confirmation_date`, `created_at`, `updated_at`) VALUES
(1, 6, 6, 5, '2026-04-03 10:28:35', 'check-up', 'scheduled', '?????? ???????? ??????', '                                            dssd', '', '                                            dssd', 'pending', NULL, '2026-04-01 07:28:35', '2026-05-06 19:59:57'),
(2, 6, 6, 5, '2026-04-03 10:35:44', 'check-up', 'completed', 'فحص دوري جيد', NULL, NULL, NULL, 'pending', '2026-05-06 21:56:44', '2026-04-01 07:35:44', '2026-05-06 19:48:59'),
(3, 6, 6, 5, '2026-04-03 09:00:00', 'check-up', 'scheduled', NULL, NULL, NULL, NULL, 'pending', '2026-04-03 22:33:19', '2026-04-03 19:33:07', '2026-04-03 19:33:19');

-- --------------------------------------------------------

--
-- بنية الجدول `appointment_analytics`
--

CREATE TABLE `appointment_analytics` (
  `id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `appointment_date` date DEFAULT NULL,
  `total_appointments` int(11) DEFAULT 0,
  `confirmed_appointments` int(11) DEFAULT 0,
  `completed_appointments` int(11) DEFAULT 0,
  `no_show_appointments` int(11) DEFAULT 0,
  `cancelled_appointments` int(11) DEFAULT 0,
  `attendance_rate` decimal(5,2) DEFAULT NULL,
  `average_consultation_duration` int(11) DEFAULT NULL COMMENT 'بالدقائق',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `appointment_attachments`
--

CREATE TABLE `appointment_attachments` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` int(11) DEFAULT NULL,
  `file_type` varchar(50) DEFAULT NULL,
  `attachment_type` enum('report','prescription','test_result','other') DEFAULT 'report',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `appointment_attachments`
--

INSERT INTO `appointment_attachments` (`id`, `appointment_id`, `uploaded_by`, `file_name`, `file_path`, `file_size`, `file_type`, `attachment_type`, `uploaded_at`) VALUES
(1, 2, 6, 'شعار logo وردي و بيج ناعم شموع معطرة.jpg', '../uploads/appointment_reports/1774643918__________logo________________________________________________.jpg', 147434, 'image/jpeg', 'report', '2026-03-27 20:38:38'),
(2, 2, 6, '593H6ppk9bqcSZ7Z2o4N.jpg', '../uploads/appointment_reports/1778096865_593H6ppk9bqcSZ7Z2o4N.jpg', 55274, 'image/jpeg', 'report', '2026-05-06 19:47:45');

-- --------------------------------------------------------

--
-- بنية الجدول `appointment_conflicts`
--

CREATE TABLE `appointment_conflicts` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `conflicting_appointment_id` int(11) DEFAULT NULL,
  `conflict_type` enum('doctor_overbooked','parent_double_booking','child_double_booking','doctor_at_clinic','emergency_slot') DEFAULT 'doctor_overbooked',
  `severity` enum('critical','warning','info') DEFAULT 'warning',
  `resolved` tinyint(1) DEFAULT 0,
  `resolution_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `appointment_notifications`
--

CREATE TABLE `appointment_notifications` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_type` enum('confirmation','reminder','follow_up') DEFAULT 'reminder',
  `sent_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL,
  `delivery_status` enum('pending','sent','failed') DEFAULT 'sent',
  `delivery_channel` enum('email','sms','in_app') DEFAULT 'in_app',
  `message_content` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `appointment_notifications`
--

INSERT INTO `appointment_notifications` (`id`, `appointment_id`, `user_id`, `notification_type`, `sent_at`, `read_at`, `delivery_status`, `delivery_channel`, `message_content`) VALUES
(1, 2, 5, 'confirmation', '2026-03-27 20:59:30', NULL, 'sent', 'in_app', '<div style=\"direction: rtl; font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; border-radius: 10px;\">\r\n    <h2 style=\"color: #dc3545;\">تأكيد الموعد الطبي</h2>\r\n    <p>السلام عليكم ورحمة الله وبركاته</p>\r\n    \r\n    <div style=\"background: white; padding: 15px; border-right: 4px solid #dc3545; margin: 15px 0;\">\r\n        <p><strong>تم تأكيد موعدك الطبي:</strong></p>\r\n        <table style=\"width: 100%; font-size: 14px; line-height: 1.8;\">\r\n            <tr>\r\n                <td style=\"width: 40%;\"><strong>الطفل:</strong></td>\r\n                <td>ayla said</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>الطبيب:</strong></td>\r\n                <td>Dr. Ahmad (Pediatrician)</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>التاريخ:</strong></td>\r\n                <td>27/03/2026</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>الوقت:</strong></td>\r\n                <td>09:00</td>\r\n            </tr>\r\n        </table>\r\n    </div>\r\n    \r\n    <p style=\"color: #666; font-size: 13px;\">\r\n        يرجى الحضور قبل 5 دقائق من الموعد المحدد.\r\n    </p>\r\n</div>'),
(2, 2, 5, 'confirmation', '2026-04-01 07:47:52', NULL, 'sent', 'in_app', '<div style=\"direction: rtl; font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; border-radius: 10px;\">\r\n    <h2 style=\"color: #dc3545;\">تأكيد الموعد الطبي</h2>\r\n    <p>السلام عليكم ورحمة الله وبركاته</p>\r\n    \r\n    <div style=\"background: white; padding: 15px; border-right: 4px solid #dc3545; margin: 15px 0;\">\r\n        <p><strong>تم تأكيد موعدك الطبي:</strong></p>\r\n        <table style=\"width: 100%; font-size: 14px; line-height: 1.8;\">\r\n            <tr>\r\n                <td style=\"width: 40%;\"><strong>الطفل:</strong></td>\r\n                <td>ayla said</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>الطبيب:</strong></td>\r\n                <td>Dr. Ahmad (Pediatrician)</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>التاريخ:</strong></td>\r\n                <td>03/04/2026</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>الوقت:</strong></td>\r\n                <td></td>\r\n            </tr>\r\n        </table>\r\n    </div>\r\n    \r\n    <p style=\"color: #666; font-size: 13px;\">\r\n        يرجى الحضور قبل 5 دقائق من الموعد المحدد.\r\n    </p>\r\n</div>'),
(3, 3, 5, 'confirmation', '2026-04-03 19:33:07', '2026-04-29 13:11:34', 'sent', 'in_app', '<div style=\"direction: rtl; font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; border-radius: 10px;\">\r\n    <h2 style=\"color: #dc3545;\">تأكيد الموعد الطبي</h2>\r\n    <p>السلام عليكم ورحمة الله وبركاته</p>\r\n    \r\n    <div style=\"background: white; padding: 15px; border-right: 4px solid #dc3545; margin: 15px 0;\">\r\n        <p><strong>تم تأكيد موعدك الطبي:</strong></p>\r\n        <table style=\"width: 100%; font-size: 14px; line-height: 1.8;\">\r\n            <tr>\r\n                <td style=\"width: 40%;\"><strong>الطفل:</strong></td>\r\n                <td>ayla said</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>الطبيب:</strong></td>\r\n                <td>Dr. Ahmad (Pediatrician)</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>التاريخ:</strong></td>\r\n                <td>03/04/2026</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>الوقت:</strong></td>\r\n                <td>09:00</td>\r\n            </tr>\r\n        </table>\r\n    </div>\r\n    \r\n    <p style=\"color: #666; font-size: 13px;\">\r\n        يرجى الحضور قبل 5 دقائق من الموعد المحدد.\r\n    </p>\r\n</div>'),
(4, 2, 5, 'confirmation', '2026-05-06 18:56:39', NULL, 'sent', 'in_app', '<div style=\"direction: rtl; font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; border-radius: 10px;\">\r\n    <h2 style=\"color: #dc3545;\">تأكيد الموعد الطبي</h2>\r\n    <p>السلام عليكم ورحمة الله وبركاته</p>\r\n    \r\n    <div style=\"background: white; padding: 15px; border-right: 4px solid #dc3545; margin: 15px 0;\">\r\n        <p><strong>تم تأكيد موعدك الطبي:</strong></p>\r\n        <table style=\"width: 100%; font-size: 14px; line-height: 1.8;\">\r\n            <tr>\r\n                <td style=\"width: 40%;\"><strong>الطفل:</strong></td>\r\n                <td>ayla said</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>الطبيب:</strong></td>\r\n                <td>Dr. Ahmad4 (Pediatrician)</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>التاريخ:</strong></td>\r\n                <td>03/04/2026</td>\r\n            </tr>\r\n            <tr>\r\n                <td><strong>الوقت:</strong></td>\r\n                <td>10:35</td>\r\n            </tr>\r\n        </table>\r\n    </div>\r\n    \r\n    <p style=\"color: #666; font-size: 13px;\">\r\n        يرجى الحضور قبل 5 دقائق من الموعد المحدد.\r\n    </p>\r\n</div>');

-- --------------------------------------------------------

--
-- بنية الجدول `appointment_ratings`
--

CREATE TABLE `appointment_ratings` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `rating` int(11) DEFAULT NULL COMMENT 'من 1 إلى 5',
  `review_text` text DEFAULT NULL,
  `rated_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `appointment_reminders`
--

CREATE TABLE `appointment_reminders` (
  `id` int(11) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `nurse_id` int(11) DEFAULT NULL,
  `reminder_type` enum('email','sms','in_app','whatsapp') DEFAULT 'in_app',
  `reminder_time_before_minutes` int(11) DEFAULT 1440,
  `reminder_sent` datetime DEFAULT NULL,
  `reminder_sent_status` enum('pending','sent','failed','bounced') DEFAULT 'pending',
  `is_read` tinyint(1) DEFAULT 0,
  `reminder_message` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `appointment_requests`
--

CREATE TABLE `appointment_requests` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `appointment_type` enum('check-up','follow-up','vaccination','consultation','emergency','emergency_call') DEFAULT 'check-up',
  `requested_date` datetime DEFAULT NULL,
  `reason_for_visit` text DEFAULT NULL,
  `preferred_times_start` time DEFAULT NULL,
  `preferred_times_end` time DEFAULT NULL,
  `urgency_level` enum('routine','urgent','emergency') DEFAULT 'routine',
  `request_status` enum('pending','accepted','rejected','scheduled','cancelled') DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `appointment_reschedule_log`
--

CREATE TABLE `appointment_reschedule_log` (
  `id` int(11) NOT NULL,
  `original_appointment_id` int(11) NOT NULL,
  `new_appointment_id` int(11) DEFAULT NULL,
  `rescheduled_from` datetime NOT NULL,
  `rescheduled_to` datetime NOT NULL,
  `rescheduled_by` int(11) NOT NULL,
  `reason` text DEFAULT NULL,
  `reschedule_type` enum('automatic','manual','conflict_resolution') DEFAULT 'manual',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `children`
--

CREATE TABLE `children` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `birth_date` date NOT NULL,
  `age` varchar(50) NOT NULL,
  `weight` float NOT NULL,
  `height` float NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_archived` tinyint(1) NOT NULL DEFAULT 0,
  `is_twin` tinyint(1) DEFAULT 0,
  `gender` enum('male','female') DEFAULT NULL,
  `twin_group` varchar(100) DEFAULT NULL,
  `nutrition_guideline_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `children`
--

INSERT INTO `children` (`id`, `user_id`, `name`, `birth_date`, `age`, `weight`, `height`, `created_at`, `is_archived`, `is_twin`, `gender`, `twin_group`, `nutrition_guideline_id`) VALUES
(6, 5, 'ayla said', '2025-06-01', '12 أشهر', 11.5, 80, '2025-06-03 14:50:41', 0, 0, NULL, NULL, 2),
(7, 5, 'youssef mohammed', '2025-03-10', '5 أشهر 15 يوم', 8, 68, '2025-06-03 15:00:00', 0, 0, NULL, NULL, 3),
(8, 8, 'laila ahmad', '2024-12-01', '10 أشهر و 23 يوم', 10.2, 75.2, '2025-09-01 10:00:00', 0, 0, NULL, NULL, 3),
(9, 8, 'ali ahmad', '2023-01-15', 'سنة و 9 أشهر', 11.5, 80, '2025-09-01 10:01:00', 0, 0, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `child_medication_reminders`
--

CREATE TABLE `child_medication_reminders` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `medication_name` varchar(255) NOT NULL,
  `dosage` varchar(100) NOT NULL,
  `reminder_time` datetime NOT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('pending','sent','completed','skipped') DEFAULT 'pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `child_medication_reminders`
--

INSERT INTO `child_medication_reminders` (`id`, `child_id`, `medication_name`, `dosage`, `reminder_time`, `notes`, `status`, `created_at`, `updated_at`) VALUES
(3, 7, 'باراسيتامول', '5ml كل 4 ساعات', '2026-04-01 09:42:00', '', 'pending', '2026-04-01 06:42:32', '2026-04-01 06:42:32'),
(4, 7, 'أموكسيسيلين', '5ml كل 8 ساعات', '2026-04-01 09:42:00', '', 'pending', '2026-04-01 06:43:03', '2026-04-01 06:43:03');

-- --------------------------------------------------------

--
-- بنية الجدول `child_vaccines`
--

CREATE TABLE `child_vaccines` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `vaccine_id` int(11) NOT NULL,
  `due_date` date NOT NULL,
  `administered_date` date DEFAULT NULL,
  `status` enum('due','administered','missed') NOT NULL DEFAULT 'due',
  `nurse_note` text DEFAULT NULL,
  `certificate_filename` varchar(255) DEFAULT NULL,
  `nurse_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `vaccine_schedule_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `child_vaccines`
--

INSERT INTO `child_vaccines` (`id`, `child_id`, `vaccine_id`, `due_date`, `administered_date`, `status`, `nurse_note`, `certificate_filename`, `nurse_id`, `created_at`, `vaccine_schedule_id`) VALUES
(1, 6, 1, '2025-08-01', '2025-08-05', 'administered', 'تم إعطاء الجرعة الأولى من شلل الأطفال في الموعد', 'cert_65373a21b3d2b.pdf', 7, '2025-08-05 09:00:00', NULL),
(2, 6, 2, '2025-08-01', '2025-08-05', 'administered', 'تم إعطاء الجرعة الأولى من الثلاثي البكتيري', 'cert_65373a21b3d2b.pdf', 7, '2025-08-05 09:00:00', NULL),
(3, 7, 1, '2025-05-10', NULL, 'missed', 'لم يحضر الأهل في الموعد المحدد', NULL, NULL, '2025-04-01 08:00:00', NULL),
(4, 6, 4, '2025-10-01', NULL, 'missed', 'فات موعد الجرعة الثانية من الروتا', NULL, NULL, '2025-09-01 09:00:00', NULL),
(5, 8, 3, '2025-12-01', '0000-00-00', 'due', 'مستحق في نهاية العام الأول', NULL, 7, '2025-10-24 09:00:00', NULL),
(6, 6, 4, '2024-02-24', '2024-02-26', 'administered', 'qq', 'cert_68fb6e3fc6f6b.png', 7, '2025-10-24 12:17:03', NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `common_symptoms`
--

CREATE TABLE `common_symptoms` (
  `id` int(11) NOT NULL,
  `symptom_name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `age_range_min_months` int(11) DEFAULT 0,
  `age_range_max_months` int(11) DEFAULT 24,
  `severity_level` enum('mild','moderate','severe') DEFAULT 'mild',
  `home_remedies` text DEFAULT NULL,
  `when_to_see_doctor` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `common_symptoms`
--

INSERT INTO `common_symptoms` (`id`, `symptom_name`, `description`, `age_range_min_months`, `age_range_max_months`, `severity_level`, `home_remedies`, `when_to_see_doctor`, `created_at`) VALUES
(9, 'التسنين', 'تورم اللثة، إفراز اللعاب، صعوبة في النوم بسبب بروز الأسنان', 3, 24, '', 'حلقات التسنين، كمادات باردة على اللثة، تدليك لطيف', 'إذا ارتفعت درجة الحرارة عن 38.5°C أو تورم شديد', '2026-02-16 12:17:54'),
(10, 'المغص', 'بكاء مفرط، انزعاج في البطن، عادة في المساء', 0, 6, '', 'الهز برفق، كمادات دافئة على البطن، التجشؤ بعد الرضاعة', 'إذا استمر لأكثر من 4 أشهر أو صاحب قيء', '2026-02-16 12:17:54'),
(11, 'طفح الحفاض', 'جلد أحمر وملتهب في منطقة الحفاض', 0, 24, '', 'تغيير الحفاضات بشكل متكرر، تعرض المنطقة للهواء، كريم الحفاض', 'إذا ساء بعد 3 أيام أو ظهرت علامات عدوى', '2026-02-16 12:17:54'),
(12, 'الإمساك', 'صعوبة في التبرز، براز صلب', 0, 24, '', 'زيادة شرب الماء، تدليك البطن بلطف، الحركة', 'إذا صاحب الإمساك حمى أو قيء أو دم في البراز', '2026-02-16 12:17:54'),
(13, 'الإسهال', 'براز متكرر سائلي أو مائي', 0, 24, '', 'الحفاظ على الترطيب بالحليب الطبيعي أو الصناعي، تغيير الحفاضات بشكل متكرر', 'إذا استمر أكثر من أسبوعين أو ظهرت علامات الجفاف', '2026-02-16 12:17:54'),
(14, 'نزلة البرد', 'سيلان الأنف، كحة خفيفة، عطس', 0, 24, '', 'قطرات أنف ملحية، مرطب، الراحة والترطيب الكافي', 'إذا ارتفعت الحرارة (>38°C)، صعوبة في التنفس، أو استمر أكثر من أسبوعين', '2026-02-16 12:17:54'),
(15, 'التهاب الأذن', 'ألم في الأذن، حمى، شد الأذن', 6, 24, '', 'كمادات دافئة، مسكنات حسب وصفة الطبيب للأطفال', 'راجع الطبيب فورًا لاحتياج محتمل للمضادات الحيوية', '2026-02-16 12:17:54'),
(16, 'الطفح الجلدي', 'أنواع مختلفة من الطفح الجلدي', 0, 24, '', 'حافظ على نظافة وجفاف المنطقة، تجنب المهيجات', 'إذا انتشر بسرعة، صاحبته حمى، أو لم يتحسن خلال 3 أيام', '2026-02-16 12:17:54');

-- --------------------------------------------------------

--
-- بنية الجدول `cron_logs`
--

CREATE TABLE `cron_logs` (
  `id` int(11) NOT NULL,
  `cron_name` varchar(100) NOT NULL,
  `status` enum('success','error','warning') DEFAULT 'success',
  `result_json` longtext DEFAULT NULL,
  `executed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `cron_logs`
--

INSERT INTO `cron_logs` (`id`, `cron_name`, `status`, `result_json`, `executed_at`) VALUES
(1, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-03 21:30:32\"}', '2026-04-03 19:30:32'),
(2, 'prescription_renewal_check', 'success', 'تم فحص الوصفات وإرسال 0 إشعار', '2026-04-03 19:31:50'),
(3, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-03 21:32:04\"}', '2026-04-03 19:32:04'),
(4, 'prescription_renewal_check', 'success', 'تم فحص الوصفات وإرسال 0 إشعار', '2026-04-03 19:35:01'),
(5, 'prescription_renewal_check', 'success', 'تم فحص الوصفات وإرسال 0 إشعار', '2026-04-03 19:36:30'),
(6, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-03 21:36:45\"}', '2026-04-03 19:36:45'),
(7, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-03 21:37:47\"}', '2026-04-03 19:37:47'),
(8, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-07 20:00:01\"}', '2026-04-07 18:00:01'),
(9, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-11 20:00:01\"}', '2026-04-11 18:00:02'),
(10, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-12 20:00:01\"}', '2026-04-12 18:00:02'),
(11, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-14 20:00:02\"}', '2026-04-14 18:00:02'),
(12, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-18 20:01:30\"}', '2026-04-18 18:01:30'),
(13, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-19 20:00:02\"}', '2026-04-19 18:00:02'),
(14, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-20 20:00:02\"}', '2026-04-20 18:00:02'),
(15, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-21 20:00:02\"}', '2026-04-21 18:00:02'),
(16, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-28 20:00:01\"}', '2026-04-28 18:00:01'),
(17, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-04-29 20:00:01\"}', '2026-04-29 18:00:01'),
(18, 'appointment_reminders', 'success', '{\"reminders_sent\":0,\"reminders_failed\":0,\"reminder_details\":[],\"timestamp\":\"2026-05-06 20:00:02\"}', '2026-05-06 18:00:02');

-- --------------------------------------------------------

--
-- بنية الجدول `daily_activities`
--

CREATE TABLE `daily_activities` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `activity_type` enum('breast_feed','formula_feed','nap','night_sleep','growth_record') NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `duration` float DEFAULT NULL,
  `quantity` float DEFAULT NULL,
  `details` varchar(255) DEFAULT NULL,
  `weight` float DEFAULT NULL,
  `height` float DEFAULT NULL,
  `temperature` float DEFAULT NULL,
  `illness` varchar(255) DEFAULT NULL,
  `medicine_name` varchar(100) DEFAULT NULL,
  `medicine_dose` varchar(50) DEFAULT NULL,
  `medicine_time` time DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `daily_activities`
--

INSERT INTO `daily_activities` (`id`, `child_id`, `date`, `activity_type`, `start_time`, `end_time`, `duration`, `quantity`, `details`, `weight`, `height`, `temperature`, `illness`, `medicine_name`, `medicine_dose`, `medicine_time`, `note`, `created_at`) VALUES
(1, 6, '2025-10-20', 'growth_record', NULL, NULL, NULL, NULL, NULL, 6.8, 63.5, 36.8, NULL, NULL, NULL, NULL, 'كانت بصحة جيدة', '2025-10-20 10:00:00'),
(2, 6, '2025-10-23', 'growth_record', NULL, NULL, NULL, NULL, NULL, 7.1, 64.5, 38.5, 'سعال خفيف', 'مسكن', '2.5 مل', '12:00:00', 'الحرارة مرتفعة قليلاً، تم إعطاؤها مسكن', '2025-10-23 11:30:00'),
(3, 6, '2025-10-23', 'night_sleep', '22:00:00', '05:30:00', 7.5, 2, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'نوم متقطع بسبب السعال', '2025-10-23 05:35:00'),
(4, 6, '2025-10-24', 'breast_feed', '08:00:00', NULL, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'رضاعة جيدة من الجهة اليمنى', '2025-10-24 08:15:00'),
(5, 7, '2025-10-15', 'growth_record', NULL, NULL, NULL, NULL, NULL, 9, 70, 36.6, NULL, NULL, NULL, NULL, 'فحص شهري', '2025-10-15 10:00:00'),
(6, 7, '2025-10-24', 'formula_feed', '10:00:00', NULL, NULL, 120, 'سيميلاك', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'شرب الكمية كاملة', '2025-10-24 10:15:00'),
(7, 7, '2026-04-03', 'growth_record', NULL, NULL, NULL, NULL, NULL, 8, 68, 36.8, '', '', '', '00:00:00', '', '2026-04-03 09:44:39'),
(8, 6, '2026-04-03', 'growth_record', NULL, NULL, NULL, NULL, NULL, 11.5, 80, 0, '', '', '', '00:00:00', '', '2026-04-03 09:46:23'),
(9, 7, '2026-04-03', 'growth_record', NULL, NULL, NULL, NULL, NULL, 6, 65, 0, '', '', '', '00:00:00', '', '2026-04-03 09:47:16'),
(10, 7, '2026-04-03', 'growth_record', NULL, NULL, NULL, NULL, NULL, 8, 68, 36.8, '', '', '', '00:00:00', '', '2026-04-03 10:15:51');

-- --------------------------------------------------------

--
-- Stand-in structure for view `dashboard_stats`
-- (See below for the actual view)
--
CREATE TABLE `dashboard_stats` (
`stat_name` varchar(14)
,`stat_value` bigint(21)
);

-- --------------------------------------------------------

--
-- بنية الجدول `doctor_schedules`
--

CREATE TABLE `doctor_schedules` (
  `id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `day_of_week` enum('Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday','Friday') NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `break_start` time DEFAULT NULL,
  `break_end` time DEFAULT NULL,
  `max_appointments_per_slot` int(11) DEFAULT 1,
  `slot_duration_minutes` int(11) DEFAULT 30,
  `is_available` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `doctor_schedules`
--

INSERT INTO `doctor_schedules` (`id`, `doctor_id`, `day_of_week`, `start_time`, `end_time`, `break_start`, `break_end`, `max_appointments_per_slot`, `slot_duration_minutes`, `is_available`, `created_at`, `updated_at`) VALUES
(1, 6, 'Sunday', '09:00:00', '17:00:00', '12:00:00', '13:00:00', 1, 30, 1, '2026-04-01 07:28:35', '2026-04-01 07:28:35'),
(2, 6, 'Tuesday', '09:00:00', '17:00:00', '12:00:00', '13:00:00', 1, 30, 1, '2026-04-01 07:28:35', '2026-04-01 07:28:35'),
(3, 6, 'Thursday', '09:00:00', '17:00:00', '12:00:00', '13:00:00', 1, 30, 1, '2026-04-01 07:28:35', '2026-04-01 07:28:35');

-- --------------------------------------------------------

--
-- بنية الجدول `doctor_settings`
--

CREATE TABLE `doctor_settings` (
  `id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `notifications` tinyint(1) DEFAULT 1,
  `email_alerts` tinyint(1) DEFAULT 1,
  `sms_alerts` tinyint(1) DEFAULT 0,
  `language` varchar(10) DEFAULT 'ar',
  `night_mode` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `doctor_unavailable_slots`
--

CREATE TABLE `doctor_unavailable_slots` (
  `id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `reason` enum('leave','holiday','personal','clinic_closed','emergency') DEFAULT 'leave',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `educational_videos`
--

CREATE TABLE `educational_videos` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `video_url` varchar(500) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `age_group` varchar(50) DEFAULT NULL,
  `author` varchar(100) NOT NULL,
  `views_count` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `educational_videos`
--

INSERT INTO `educational_videos` (`id`, `title`, `description`, `video_url`, `category`, `age_group`, `author`, `views_count`, `created_at`) VALUES
(1, 'كيفية إرضاع الطفل', 'دليل شامل لإرضاع الطفل بشكل صحيح', 'https://www.youtube.com/embed/example1', 'تغذية', '0-6 أشهر', 'د. سارة أحمد', 152, '2023-12-31 21:00:00'),
(2, 'علامات صحة الطفل', 'كيفية التعرف على علامات الصحة الجيدة لدى الطفل', 'https://www.youtube.com/embed/example2', 'صحة عامة', '0-12 شهر', 'د. محمد علي', 201, '2023-12-31 21:00:00'),
(3, 'Qui ut minima repudi', 'Distinctio Expedita', 'https://www.wyzajywuh.us', 'nutrition', '1-3', 'Dr. Ahmad (Pediatrician)', 0, '2026-05-06 17:16:50');

-- --------------------------------------------------------

--
-- بنية الجدول `error_logs`
--

CREATE TABLE `error_logs` (
  `id` int(11) NOT NULL,
  `error_type` varchar(100) NOT NULL,
  `error_message` text NOT NULL,
  `file` varchar(255) DEFAULT NULL,
  `line` int(11) DEFAULT NULL,
  `stack_trace` text DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `expired_prescriptions_view`
-- (See below for the actual view)
--
CREATE TABLE `expired_prescriptions_view` (
`id` int(11)
,`child_id` int(11)
,`child_name` varchar(100)
,`doctor_id` int(11)
,`doctor_name` varchar(100)
,`prescription_date` date
,`expiry_date` date
,`days_expired` int(7)
,`status` enum('active','expired','cancelled')
,`medication_count` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `expiring_prescriptions_view`
-- (See below for the actual view)
--
CREATE TABLE `expiring_prescriptions_view` (
`id` int(11)
,`child_id` int(11)
,`child_name` varchar(100)
,`doctor_id` int(11)
,`doctor_name` varchar(100)
,`prescription_date` date
,`expiry_date` date
,`days_until_expiry` int(7)
,`status` enum('active','expired','cancelled')
,`medication_count` bigint(21)
);

-- --------------------------------------------------------

--
-- بنية الجدول `feeding_schedule`
--

CREATE TABLE `feeding_schedule` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `scheduled_time` datetime NOT NULL,
  `type` enum('breast','formula') NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `feeding_schedule`
--

INSERT INTO `feeding_schedule` (`id`, `child_id`, `scheduled_time`, `type`, `created_at`) VALUES
(1, 6, '2026-03-11 09:00:00', 'breast', '2026-03-11 12:47:33'),
(2, 7, '2026-03-11 11:30:00', 'formula', '2026-03-11 12:47:33'),
(3, 8, '2026-03-11 14:00:00', 'breast', '2026-03-11 12:47:33');

-- --------------------------------------------------------

--
-- بنية الجدول `growth_measurements`
--

CREATE TABLE `growth_measurements` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `doctor_id` int(11) DEFAULT NULL,
  `age_months` int(11) NOT NULL,
  `weight_kg` decimal(5,2) DEFAULT NULL,
  `height_cm` decimal(5,2) DEFAULT NULL,
  `head_circumference_cm` decimal(5,2) DEFAULT NULL,
  `bmi` decimal(4,2) DEFAULT NULL,
  `growth_percentile` int(11) DEFAULT NULL,
  `measurement_date` date NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `growth_measurements`
--

INSERT INTO `growth_measurements` (`id`, `child_id`, `doctor_id`, `age_months`, `weight_kg`, `height_cm`, `head_circumference_cm`, `bmi`, `growth_percentile`, `measurement_date`, `notes`, `created_at`) VALUES
(8, 7, 6, 6, 8.00, 68.00, 42.00, 17.30, 50, '2026-04-03', 'تسجيل نمو تلقائي من النشاط اليومي', '2026-04-03 09:44:39'),
(9, 6, NULL, 12, 11.50, 80.00, 42.00, 17.97, 91, '2026-04-03', 'تسجيل نمو تلقائي من النشاط اليومي', '2026-04-03 09:46:23'),
(10, 7, 6, 12, 6.00, 65.00, 42.00, 14.20, 1, '2026-04-03', 'تسجيل نمو تلقائي من النشاط اليومي', '2026-04-03 09:47:16'),
(11, 7, 6, 6, 8.00, 68.00, 42.00, 17.30, 50, '2026-04-03', 'تسجيل نمو تلقائي من النشاط اليومي', '2026-04-03 10:15:51');

-- --------------------------------------------------------

--
-- بنية الجدول `growth_standards`
--

CREATE TABLE `growth_standards` (
  `id` int(11) NOT NULL,
  `age_months` int(11) NOT NULL,
  `gender` enum('male','female','both') DEFAULT 'both',
  `avg_weight_kg` float NOT NULL,
  `weight_upper_percentile_kg` float NOT NULL,
  `weight_lower_percentile_kg` float NOT NULL,
  `avg_height_cm` float NOT NULL,
  `height_upper_percentile_cm` float NOT NULL,
  `height_lower_percentile_cm` float NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `growth_standards`
--

INSERT INTO `growth_standards` (`id`, `age_months`, `gender`, `avg_weight_kg`, `weight_upper_percentile_kg`, `weight_lower_percentile_kg`, `avg_height_cm`, `height_upper_percentile_cm`, `height_lower_percentile_cm`, `description`, `created_at`) VALUES
(1, 0, 'both', 3.5, 4.3, 2.7, 50, 52, 48, 'At Birth', '2026-02-16 09:40:25'),
(2, 1, 'both', 4.3, 5.1, 3.5, 54.6, 57, 52, '1 Month', '2026-02-16 09:40:25'),
(3, 2, 'both', 5.1, 6, 4.2, 58.4, 60.8, 56, '2 Months', '2026-02-16 09:40:25'),
(4, 3, 'both', 6, 7, 5, 61.6, 64.1, 59, '3 Months', '2026-02-16 09:40:25'),
(5, 4, 'both', 7, 8.3, 5.8, 64, 66.7, 61.3, '4 Months', '2026-02-16 09:40:25'),
(6, 6, 'both', 8.2, 9.7, 7, 67.6, 70.3, 65, '6 Months', '2026-02-16 09:40:25'),
(7, 9, 'both', 9.2, 11, 7.8, 71.3, 74, 68.5, '9 Months', '2026-02-16 09:40:25'),
(8, 12, 'both', 10.2, 12.2, 8.6, 75.1, 78, 72, '12 Months', '2026-02-16 09:40:25'),
(9, 18, 'both', 11.8, 14, 10, 80, 83.5, 76.5, '18 Months', '2026-02-16 09:40:25'),
(10, 24, 'both', 13.5, 16, 11.5, 86, 89.5, 82.5, '24 Months', '2026-02-16 09:40:25');

-- --------------------------------------------------------

--
-- بنية الجدول `guest_ai_analysis`
--

CREATE TABLE `guest_ai_analysis` (
  `id` int(11) NOT NULL,
  `guest_name` varchar(100) DEFAULT NULL,
  `guest_email` varchar(100) DEFAULT NULL,
  `analysis_type` enum('growth_prediction','cry_analysis','symptom_check') NOT NULL,
  `input_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`input_data`)),
  `ai_result` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`ai_result`)),
  `confidence_score` float DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `guest_ai_analysis`
--

INSERT INTO `guest_ai_analysis` (`id`, `guest_name`, `guest_email`, `analysis_type`, `input_data`, `ai_result`, `confidence_score`, `created_at`) VALUES
(1, 'ddd', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"ddd\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"Consult doctor if >38.5u00b0C or lasts >3 days\",\"home_care\":\"Keep hydrated, light clothing, monitor temperature\",\"normal_range\":\"36.5-37.5u00b0C\",\"urgency\":\"LOW - Monitor and follow guidance\"}', NULL, '2026-02-16 09:45:02'),
(2, 'ugh', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"rash\",\"temperature\":\"38.5\",\"duration_hours\":\"2\",\"age_months\":\"12\",\"guest_name\":\"ugh\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"Consult with pediatrician\",\"home_care\":\"Monitor baby closely\",\"normal_range\":\"Information not available\",\"urgency\":\"LOW - Monitor and follow guidance\"}', NULL, '2026-02-16 10:10:33'),
(3, 'ugh', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"38.5\",\"duration_hours\":\"2\",\"age_months\":\"12\",\"guest_name\":\"ugh\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"Consult doctor if >38.5u00b0C or lasts >3 days\",\"home_care\":\"Keep hydrated, light clothing, monitor temperature\",\"normal_range\":\"36.5-37.5u00b0C\",\"urgency\":\"LOW - Monitor and follow guidance\"}', NULL, '2026-02-16 10:10:40'),
(4, 'ugh', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"38.5\",\"duration_hours\":\"2\",\"age_months\":\"3\",\"guest_name\":\"ugh\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"Consult doctor if >38.5u00b0C or lasts >3 days\",\"home_care\":\"Keep hydrated, light clothing, monitor temperature\",\"normal_range\":\"36.5-37.5u00b0C\",\"urgency\":\"LOW - Monitor and follow guidance\"}', NULL, '2026-02-16 10:11:33'),
(5, 'ugh', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"38.5\",\"duration_hours\":\"48\",\"age_months\":\"3\",\"guest_name\":\"ugh\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"Consult doctor if >38.5u00b0C or lasts >3 days\",\"home_care\":\"Keep hydrated, light clothing, monitor temperature\",\"normal_range\":\"36.5-37.5u00b0C\",\"urgency\":\"LOW - Monitor and follow guidance\"}', NULL, '2026-02-16 10:12:42'),
(6, 'ddd', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"38.5\",\"duration_hours\":\"24\",\"age_months\":\"3\",\"guest_name\":\"ddd\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0643u0627u0646u062a u062fu0631u062cu0629 u0627u0644u062du0631u0627u0631u0629 >38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a >3 u0623u064au0627u0645\",\"home_care\":\"u062du0627u0641u0638 u0639u0644u0649 u0627u0644u0631u0637u0648u0628u0629u060c u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0631u0627u0642u0628 u062fu0631u062cu0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5-37.5u00b0u0645\",\"urgency\":\"LOW - u0631u0627u0642u0628 u0648u0627u062au0628u0639 u0627u0644u062au0648u062cu064au0647u0627u062a\"}', NULL, '2026-02-16 10:14:58'),
(7, 'ugh', 'ola@gmail.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"40\",\"intensity_1_10\":\"6\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":null,\"age_months\":\"4\",\"guest_name\":\"ugh\",\"guest_email\":\"ola@gmail.com\"}', '{\"analysis_timestamp\":\"2026-02-16T13:15:59.326035\",\"confidence\":0.73,\"detailed_analysis\":[{\"cause\":\"discomfort\",\"confidence\":0.73,\"description\":\"Sudden, sharp cries with pauses\",\"intensity_level\":6,\"solution\":\"Check diaper, temperature, clothing\"},{\"cause\":\"overstimulated\",\"confidence\":0.7,\"description\":\"Escalating, persistent crying\",\"intensity_level\":8,\"solution\":\"Reduce stimulation, use white noise, dim lights\"},{\"cause\":\"hunger\",\"confidence\":0.3,\"description\":\"Rhythmic, pattern-based cry\",\"intensity_level\":7,\"solution\":\"Feed the baby\"}],\"primary_cause\":\"discomfort\",\"urgent_recommendation\":\"Monitor and try suggested solutions. Consult doctor if cry persists.\"}', 0.73, '2026-02-16 10:15:59'),
(8, 'علي', 'parent@example.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"600\",\"intensity_1_10\":\"9\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"45\",\"age_months\":\"2\",\"guest_name\":\"u0639u0644u064a\",\"guest_email\":\"parent@example.com\"}', '{\"analysis_timestamp\":\"2026-02-16T13:21:27.212814\",\"confidence\":0.75,\"detailed_analysis\":[{\"cause\":\"pain\",\"confidence\":0.75,\"description\":\"High-pitched, continuous wailing\",\"intensity_level\":9,\"solution\":\"Check for injury, illness, or contact pediatrician\"},{\"cause\":\"overstimulated\",\"confidence\":0.7,\"description\":\"Escalating, persistent crying\",\"intensity_level\":8,\"solution\":\"Reduce stimulation, use white noise, dim lights\"},{\"cause\":\"hunger\",\"confidence\":0.54,\"description\":\"Rhythmic, pattern-based cry\",\"intensity_level\":7,\"solution\":\"Feed the baby\"}],\"primary_cause\":\"pain\",\"urgent_recommendation\":\"Monitor and try suggested solutions. Consult doctor if cry persists.\"}', 0.75, '2026-02-16 10:21:27'),
(9, 'آدم', 'ola@gmail.com', 'growth_prediction', '{\"age_months\":6,\"weight\":8.2,\"height\":67,\"gender\":\"male\"}', '{\"age_months\":6,\"average_percentile\":46.3,\"confidence_score\":0.92,\"current_height\":67,\"current_weight\":8.2,\"height_percentile\":42.6,\"message\":\"u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0645u062au0648u0633u0637.\",\"prediction_date\":\"2026-02-16T14:07:46.590758\",\"recommendations\":[\"u0632u064au0627u062fu0629 u0627u0644u0633u0639u0631u0627u062a u0627u0644u062du0631u0627u0631u064au0629 u0628u0634u0643u0644 u0635u062du064a\",\"u062au0642u0633u064au0645 u0627u0644u0648u062cu0628u0627u062a u0625u0644u0649 u0643u0645u064au0627u062a u0623u0635u063au0631 u0648u0645u062au0643u0631u0631u0629\",\"u0645u0631u0627u0642u0628u0629 u0627u0644u0648u0632u0646 u0623u0633u0628u0648u0639u064au0627u064b\"],\"status\":\"u0623u0642u0644_u0645u0646_u0627u0644u0645u0639u062fu0644\",\"weight_percentile\":50}', 0.92, '2026-02-16 11:07:46'),
(10, 'آدم', 'test@test.com', 'growth_prediction', '{\"age_months\":6,\"weight\":8.2,\"height\":67,\"gender\":\"male\"}', '{\"age_months\":6,\"average_percentile\":46.3,\"confidence_score\":0.92,\"current_height\":67,\"current_weight\":8.2,\"height_percentile\":42.6,\"message\":\"u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0645u062au0648u0633u0637.\",\"prediction_date\":\"2026-02-16T14:10:36.569248\",\"recommendations\":[\"u0632u064au0627u062fu0629 u0627u0644u0633u0639u0631u0627u062a u0627u0644u062du0631u0627u0631u064au0629 u0628u0634u0643u0644 u0635u062du064a\",\"u062au0642u0633u064au0645 u0627u0644u0648u062cu0628u0627u062a u0625u0644u0649 u0643u0645u064au0627u062a u0623u0635u063au0631 u0648u0645u062au0643u0631u0631u0629\",\"u0645u0631u0627u0642u0628u0629 u0627u0644u0648u0632u0646 u0623u0633u0628u0648u0639u064au0627u064b\"],\"status\":\"u0623u0642u0644_u0645u0646_u0627u0644u0645u0639u062fu0644\",\"weight_percentile\":50}', 0.92, '2026-02-16 11:10:36'),
(11, 'آدم', 'test@test.com', 'growth_prediction', '{\"age_months\":12,\"weight\":6,\"height\":65,\"gender\":\"male\"}', '{\"age_months\":12,\"average_percentile\":1,\"confidence_score\":0.92,\"current_height\":65,\"current_weight\":6,\"height_percentile\":1,\"message\":\"u26a0ufe0f u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0642u0644u0642.\",\"prediction_date\":\"2026-02-16T14:11:04.992489\",\"recommendations\":[\"u26a0ufe0f u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b\",\"u0641u062du0635 u0634u0627u0645u0644 u0644u0644u062du0627u0644u0629 u0627u0644u0635u062du064au0629\",\"u0645u062au0627u0628u0639u0629 u0637u0628u064au0629 u0645u0633u062au0645u0631u0629\"],\"status\":\"u062eu0637u064au0631\",\"weight_percentile\":1}', 0.92, '2026-02-16 11:11:04'),
(12, 'آدم', 'test@test.com', 'growth_prediction', '{\"age_months\":12,\"weight\":6,\"height\":65,\"gender\":\"male\"}', '{\"age_months\":12,\"average_percentile\":1,\"confidence_score\":0.92,\"current_height\":65,\"current_weight\":6,\"height_percentile\":1,\"message\":\"u26a0ufe0f u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0642u0644u0642.\",\"prediction_date\":\"2026-02-16T14:11:30.062330\",\"recommendations\":[\"u26a0ufe0f u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b\",\"u0641u062du0635 u0634u0627u0645u0644 u0644u0644u062du0627u0644u0629 u0627u0644u0635u062du064au0629\",\"u0645u062au0627u0628u0639u0629 u0637u0628u064au0629 u0645u0633u062au0645u0631u0629\"],\"status\":\"u062eu0637u064au0631\",\"weight_percentile\":1}', 0.92, '2026-02-16 11:11:30'),
(13, 'علي', 'parent@example.com', 'growth_prediction', '{\"age_months\":6,\"weight\":6.5,\"height\":65,\"gender\":\"male\"}', '{\"age_months\":6,\"average_percentile\":9.47,\"confidence_score\":0.92,\"current_height\":65,\"current_weight\":6.5,\"height_percentile\":17.95,\"message\":\"u26a0ufe0f u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0642u0644u0642.\",\"prediction_date\":\"2026-02-16T14:11:45.615487\",\"recommendations\":[\"u26a0ufe0f u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b\",\"u0641u062du0635 u0634u0627u0645u0644 u0644u0644u062du0627u0644u0629 u0627u0644u0635u062du064au0629\",\"u0645u062au0627u0628u0639u0629 u0637u0628u064au0629 u0645u0633u062au0645u0631u0629\"],\"status\":\"u062eu0637u064au0631\",\"weight_percentile\":1}', 0.92, '2026-02-16 11:11:45'),
(14, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"vomiting\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au0643u0631u0631 u0623u0643u062bu0631 u0645u0646 3 u0645u0631u0627u062a\",\"arabic_name\":\"u0642u064au0621\",\"home_care\":\"u0625u0639u0637u0627u0621 u0633u0648u0627u0626u0644 u0628u0643u0645u064au0627u062a u0635u063au064au0631u0629 u0648u0645u062au0643u0631u0631u0629\",\"normal_range\":\"u0645u0631u0627u062a u0642u0644u064au0644u0629 u0642u062f u062au0643u0648u0646 u0637u0628u064au0639u064au0629\"}', NULL, '2026-02-16 11:21:27'),
(15, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"vomiting\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au0643u0631u0631 u0623u0643u062bu0631 u0645u0646 3 u0645u0631u0627u062a\",\"arabic_name\":\"u0642u064au0621\",\"home_care\":\"u0625u0639u0637u0627u0621 u0633u0648u0627u0626u0644 u0628u0643u0645u064au0627u062a u0635u063au064au0631u0629 u0648u0645u062au0643u0631u0631u0629\",\"normal_range\":\"u0645u0631u0627u062a u0642u0644u064au0644u0629 u0642u062f u062au0643u0648u0646 u0637u0628u064au0639u064au0629\"}', NULL, '2026-02-16 11:21:41'),
(16, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-16 11:27:00'),
(17, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-16 11:27:02'),
(18, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-16 11:27:03'),
(19, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-16 11:27:05'),
(20, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"cough\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0643u0627u0646 u0634u062fu064au062fu0627u064b u0623u0648 u0645u0639 u0635u0639u0648u0628u0629 u062au0646u0641u0633\",\"arabic_name\":\"u0633u0639u0627u0644\",\"home_care\":\"u062cu0647u0627u0632 u062au0631u0637u064au0628u060c u0633u0648u0627u0626u0644 u062fu0627u0641u0626u0629\",\"normal_range\":\"u0627u0644u0633u0639u0627u0644 u0627u0644u062eu0641u064au0641 u0637u0628u064au0639u064a\"}', NULL, '2026-02-16 11:27:56'),
(21, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"cough\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0643u0627u0646 u0634u062fu064au062fu0627u064b u0623u0648 u0645u0639 u0635u0639u0648u0628u0629 u062au0646u0641u0633\",\"arabic_name\":\"u0633u0639u0627u0644\",\"home_care\":\"u062cu0647u0627u0632 u062au0631u0637u064au0628u060c u0633u0648u0627u0626u0644 u062fu0627u0641u0626u0629\",\"normal_range\":\"u0627u0644u0633u0639u0627u0644 u0627u0644u062eu0641u064au0641 u0637u0628u064au0639u064a\"}', NULL, '2026-02-16 11:28:01'),
(22, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"cough\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0643u0627u0646 u0634u062fu064au062fu0627u064b u0623u0648 u0645u0639 u0635u0639u0648u0628u0629 u062au0646u0641u0633\",\"arabic_name\":\"u0633u0639u0627u0644\",\"home_care\":\"u062cu0647u0627u0632 u062au0631u0637u064au0628u060c u0633u0648u0627u0626u0644 u062fu0627u0641u0626u0629\",\"normal_range\":\"u0627u0644u0633u0639u0627u0644 u0627u0644u062eu0641u064au0641 u0637u0628u064au0639u064a\"}', NULL, '2026-02-16 11:28:07'),
(23, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"cough\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0643u0627u0646 u0634u062fu064au062fu0627u064b u0623u0648 u0645u0639 u0635u0639u0648u0628u0629 u062au0646u0641u0633\",\"arabic_name\":\"u0633u0639u0627u0644\",\"home_care\":\"u062cu0647u0627u0632 u062au0631u0637u064au0628u060c u0633u0648u0627u0626u0644 u062fu0627u0641u0626u0629\",\"normal_range\":\"u0627u0644u0633u0639u0627u0644 u0627u0644u062eu0641u064au0641 u0637u0628u064au0639u064a\"}', NULL, '2026-02-16 11:38:16'),
(24, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"cough\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0643u0627u0646 u0634u062fu064au062fu0627u064b u0623u0648 u0645u0639 u0635u0639u0648u0628u0629 u062au0646u0641u0633\",\"arabic_name\":\"u0633u0639u0627u0644\",\"home_care\":\"u062cu0647u0627u0632 u062au0631u0637u064au0628u060c u0633u0648u0627u0626u0644 u062fu0627u0641u0626u0629\",\"normal_range\":\"u0627u0644u0633u0639u0627u0644 u0627u0644u062eu0641u064au0641 u0637u0628u064au0639u064a\"}', NULL, '2026-02-16 11:38:38'),
(25, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"diarrhea\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0631u0627u062cu0639 u0627u0644u0637u0628u064au0628 u0639u0646u062f u0638u0647u0648u0631 u062cu0641u0627u0641\",\"arabic_name\":\"u0625u0633u0647u0627u0644\",\"home_care\":\"u0627u0644u0627u0633u062au0645u0631u0627u0631 u0641u064a u0627u0644u0631u0636u0627u0639u0629\",\"normal_range\":\"u0627u0644u0628u0631u0627u0632 u0627u0644u0631u062eu0648 u0634u0627u0626u0639 u0639u0646u062f u0627u0644u0631u0636u0639\"}', NULL, '2026-02-16 11:39:17'),
(26, 'ddd', 'ola@gmail.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"44\",\"intensity_1_10\":\"5\",\"time_of_day\":\"afternoon\",\"last_fed_minutes_ago\":null,\"age_months\":\"4\",\"guest_name\":\"ddd\",\"guest_email\":\"ola@gmail.com\"}', '{\"analysis_timestamp\":\"2026-02-16T14:39:35.013379\",\"confidence\":0.79,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636 u0623u0648 u0627u0644u0645u0644u0627u0628u0633\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u062au0642u0637u0639 u0645u0639 u062au0648u0642u0641u0627u062a\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":6,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.79},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0625u0631u0636u0627u0639 u0627u0644u0637u0641u0644 u0641u0648u0631u0627u064b\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u0646u062au0638u0645 u0648u0645u062au0643u0631u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":7,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0648u062cu0648u062f u0625u0635u0627u0628u0629 u0623u0648 u062du0631u0627u0631u0629\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u062du0627u062f u0648u0645u0633u062au0645u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":9,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.2}],\"primary_cause\":\"discomfort\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0648u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644.\"}', 0.79, '2026-02-16 11:39:35'),
(27, 'ddd', 'ola@gmail.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"44\",\"intensity_1_10\":\"5\",\"time_of_day\":\"afternoon\",\"last_fed_minutes_ago\":null,\"age_months\":\"4\",\"guest_name\":\"ddd\",\"guest_email\":\"ola@gmail.com\"}', '{\"analysis_timestamp\":\"2026-02-16T14:39:53.241159\",\"confidence\":0.78,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636 u0623u0648 u0627u0644u0645u0644u0627u0628u0633\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u062au0642u0637u0639 u0645u0639 u062au0648u0642u0641u0627u062a\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":6,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.78},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0625u0631u0636u0627u0639 u0627u0644u0637u0641u0644 u0641u0648u0631u0627u064b\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u0646u062au0638u0645 u0648u0645u062au0643u0631u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":7,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0648u062cu0648u062f u0625u0635u0627u0628u0629 u0623u0648 u062du0631u0627u0631u0629\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u062du0627u062f u0648u0645u0633u062au0645u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":9,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.2}],\"primary_cause\":\"discomfort\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0648u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644.\"}', 0.78, '2026-02-16 11:39:53'),
(28, 'ddd', 'ola@gmail.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"44\",\"intensity_1_10\":\"5\",\"time_of_day\":\"afternoon\",\"last_fed_minutes_ago\":null,\"age_months\":\"4\",\"guest_name\":\"ddd\",\"guest_email\":\"ola@gmail.com\"}', '{\"analysis_timestamp\":\"2026-02-16T14:40:05.919411\",\"confidence\":0.76,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636 u0623u0648 u0627u0644u0645u0644u0627u0628u0633\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u062au0642u0637u0639 u0645u0639 u062au0648u0642u0641u0627u062a\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":6,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.76},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0625u0631u0636u0627u0639 u0627u0644u0637u0641u0644 u0641u0648u0631u0627u064b\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u0646u062au0638u0645 u0648u0645u062au0643u0631u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":7,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0648u062cu0648u062f u0625u0635u0627u0628u0629 u0623u0648 u062du0631u0627u0631u0629\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u062du0627u062f u0648u0645u0633u062au0645u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":9,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.2}],\"primary_cause\":\"discomfort\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0648u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644.\"}', 0.76, '2026-02-16 11:40:05'),
(29, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"diarrhea\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0631u0627u062cu0639 u0627u0644u0637u0628u064au0628 u0639u0646u062f u0638u0647u0648u0631 u062cu0641u0627u0641\",\"arabic_name\":\"u0625u0633u0647u0627u0644\",\"home_care\":\"u0627u0644u0627u0633u062au0645u0631u0627u0631 u0641u064a u0627u0644u0631u0636u0627u0639u0629\",\"normal_range\":\"u0627u0644u0628u0631u0627u0632 u0627u0644u0631u062eu0648 u0634u0627u0626u0639 u0639u0646u062f u0627u0644u0631u0636u0639\"}', NULL, '2026-02-16 11:40:22'),
(30, 'ddd', 'parent@example.com', 'growth_prediction', '{\"age_months\":2,\"weight\":20,\"height\":100,\"gender\":\"male\"}', '{\"age_months\":2,\"average_percentile\":99,\"confidence_score\":0.92,\"current_height\":100,\"current_weight\":20,\"height_percentile\":99,\"message\":\"u0627u0644u0646u0645u0648 u0623u0639u0644u0649 u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0644u062du0648u0638.\",\"prediction_date\":\"2026-02-16T14:40:54.060606\",\"recommendations\":[\"u0645u0631u0627u0642u0628u0629 u0627u0644u0646u0638u0627u0645 u0627u0644u063au0630u0627u0626u064a\",\"u062au062cu0646u0628 u0627u0644u0625u0641u0631u0627u0637 u0641u064a u0627u0644u062au063au0630u064au0629\",\"u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0644u062au0642u064au064au0645 u0627u0644u0646u0645u0648\"],\"status\":\"u0645u0631u062au0641u0639_u062cu062fu0627u064b\",\"weight_percentile\":99}', 0.92, '2026-02-16 11:40:54'),
(31, '??????', 'test@test.com', 'growth_prediction', '{\"age_months\":6,\"weight\":7.5,\"height\":67,\"gender\":\"male\"}', '{\"age_months\":6,\"average_percentile\":21.8,\"confidence_score\":0.92,\"current_height\":67,\"current_weight\":7.5,\"height_percentile\":42.6,\"message\":\"u0627u0644u0646u0645u0648 u0645u0646u062eu0641u0636 u0648u064au0633u062au062du0633u0646 u0627u0633u062au0634u0627u0631u0629 u0627u0644u0637u0628u064au0628.\",\"prediction_date\":\"2026-02-16T14:42:52.827581\",\"recommendations\":[\"u0627u0633u062au0634u0627u0631u0629 u0637u0628u064au0628 u0627u0644u0623u0637u0641u0627u0644\",\"u0625u062cu0631u0627u0621 u062au062du0627u0644u064au0644 u0639u0646u062f u0627u0644u062du0627u062cu0629\",\"u0645u0631u0627u062cu0639u0629 u0646u0645u0637 u0627u0644u0631u0636u0627u0639u0629\"],\"status\":\"u0645u0646u062eu0641u0636\",\"weight_percentile\":1}', 0.92, '2026-02-16 11:42:52'),
(32, 'آدم', 'ola@gmail.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"45\",\"intensity_1_10\":\"5\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":null,\"age_months\":\"5\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"analysis_timestamp\":\"2026-02-16T14:43:40.055206\",\"confidence\":0.8,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0647u064au0626u0629 u0628u064au0626u0629 u0646u0648u0645 u0647u0627u062fu0626u0629\",\"u0627u0644u0633u0628u0628\":\"u0646u0639u0627u0633\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u062eu0641u064au0641 u0648u0645u062au0630u0645u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":4,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.8},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636 u0623u0648 u0627u0644u0645u0644u0627u0628u0633\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u062au0642u0637u0639 u0645u0639 u062au0648u0642u0641u0627u062a\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":6,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.71},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0625u0631u0636u0627u0639 u0627u0644u0637u0641u0644 u0641u0648u0631u0627u064b\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u0646u062au0638u0645 u0648u0645u062au0643u0631u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":7,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"tired\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0648u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644.\"}', 0.8, '2026-02-16 11:43:40'),
(33, 'آدم', 'ola@gmail.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"vomiting\",\"temperature\":\"36.5\",\"duration_hours\":\"1\",\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au0643u0631u0631 u0623u0643u062bu0631 u0645u0646 3 u0645u0631u0627u062a\",\"arabic_name\":\"u0642u064au0621\",\"home_care\":\"u0625u0639u0637u0627u0621 u0633u0648u0627u0626u0644 u0628u0643u0645u064au0627u062a u0635u063au064au0631u0629 u0648u0645u062au0643u0631u0631u0629\",\"normal_range\":\"u0645u0631u0627u062a u0642u0644u064au0644u0629 u0642u062f u062au0643u0648u0646 u0637u0628u064au0639u064au0629\"}', NULL, '2026-02-16 11:43:58'),
(34, 'آدم', 'parent@example.com', 'growth_prediction', '{\"age_months\":6,\"weight\":7,\"height\":50,\"gender\":\"male\"}', '{\"age_months\":6,\"average_percentile\":1,\"confidence_score\":0.92,\"current_height\":50,\"current_weight\":7,\"height_percentile\":1,\"message\":\"u26a0ufe0f u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0642u0644u0642.\",\"prediction_date\":\"2026-02-16T14:55:56.620034\",\"recommendations\":[\"u26a0ufe0f u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b\",\"u0641u062du0635 u0634u0627u0645u0644 u0644u0644u062du0627u0644u0629 u0627u0644u0635u062du064au0629\",\"u0645u062au0627u0628u0639u0629 u0637u0628u064au0629 u0645u0633u062au0645u0631u0629\"],\"status\":\"u062eu0637u064au0631\",\"weight_percentile\":1}', 0.92, '2026-02-16 11:55:56'),
(35, 'آدم', 'ola@gmail.com', 'growth_prediction', '{\"age_months\":4,\"weight\":7,\"height\":60,\"gender\":\"male\"}', '{\"age_months\":4,\"average_percentile\":63.68,\"confidence_score\":0.92,\"current_height\":60,\"current_weight\":7,\"height_percentile\":28.35,\"message\":\"u0646u0645u0648 u0627u0644u0637u0641u0644 u0636u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a.\",\"prediction_date\":\"2026-02-16T14:57:14.189366\",\"recommendations\":[\"u0627u0644u062du0641u0627u0638 u0639u0644u0649 u062cu062fu0648u0644 u062au063au0630u064au0629 u0645u0646u062au0638u0645\",\"u0645u062au0627u0628u0639u0629 u0645u0631u0627u062du0644 u0627u0644u062au0637u0648u0631\",\"u062au0646u0638u064au0645 u0627u0644u0646u0648u0645\"],\"status\":\"u0637u0628u064au0639u064a\",\"weight_percentile\":99}', 0.92, '2026-02-16 11:57:14'),
(36, 'آدم', 'ola@gmail.com', 'growth_prediction', '{\"age_months\":5,\"weight\":20,\"height\":60,\"gender\":\"male\"}', '{\"age_months\":5,\"average_percentile\":50,\"confidence_score\":0.92,\"current_height\":60,\"current_weight\":20,\"height_percentile\":1,\"message\":\"u0646u0645u0648 u0627u0644u0637u0641u0644 u0636u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a.\",\"prediction_date\":\"2026-02-16T15:15:10.989389\",\"recommendations\":[\"u0627u0644u062du0641u0627u0638 u0639u0644u0649 u062cu062fu0648u0644 u062au063au0630u064au0629 u0645u0646u062au0638u0645\",\"u0645u062au0627u0628u0639u0629 u0645u0631u0627u062du0644 u0627u0644u062au0637u0648u0631\",\"u062au0646u0638u064au0645 u0627u0644u0646u0648u0645\"],\"status\":\"u0637u0628u064au0639u064a\",\"weight_percentile\":99}', 0.92, '2026-02-16 12:15:10'),
(37, 'آدم', 'ola@gmail.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"45\",\"intensity_1_10\":\"8\",\"time_of_day\":\"morning\",\"last_fed_minutes_ago\":null,\"age_months\":\"6\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"ola@gmail.com\"}', '{\"analysis_timestamp\":\"2026-02-16T15:15:32.595288\",\"confidence\":0.3,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0625u0631u0636u0627u0639 u0627u0644u0637u0641u0644 u0641u0648u0631u0627u064b\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u0646u062au0638u0645 u0648u0645u062au0643u0631u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":7,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636 u0623u0648 u0627u0644u0645u0644u0627u0628u0633\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u062au0642u0637u0639 u0645u0639 u062au0648u0642u0641u0627u062a\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":6,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0648u062cu0648u062f u0625u0635u0627u0628u0629 u0623u0648 u062du0631u0627u0631u0629\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u062du0627u062f u0648u0645u0633u062au0645u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":9,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.2}],\"primary_cause\":\"hunger\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0648u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644.\"}', 0.3, '2026-02-16 12:15:32'),
(38, 'آدم', 'parent@example.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"cough\",\"temperature\":\"36.5\",\"duration_hours\":\"50\",\"age_months\":\"12\",\"guest_name\":\"u0622u062fu0645\",\"guest_email\":\"parent@example.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0643u0627u0646 u0634u062fu064au062fu0627u064b u0623u0648 u0645u0639 u0635u0639u0648u0628u0629 u062au0646u0641u0633\",\"arabic_name\":\"u0633u0639u0627u0644\",\"home_care\":\"u062cu0647u0627u0632 u062au0631u0637u064au0628u060c u0633u0648u0627u0626u0644 u062fu0627u0641u0626u0629\",\"normal_range\":\"u0627u0644u0633u0639u0627u0644 u0627u0644u062eu0641u064au0641 u0637u0628u064au0639u064a\"}', NULL, '2026-02-16 12:16:09'),
(39, 'علا', 'rahaf@admin.com', 'growth_prediction', '{\"age_months\":5,\"weight\":5,\"height\":40,\"gender\":\"female\"}', '{\"age_months\":5,\"average_percentile\":1,\"confidence_score\":0.92,\"current_height\":40,\"current_weight\":5,\"height_percentile\":1,\"message\":\"u26a0ufe0f u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0642u0644u0642.\",\"prediction_date\":\"2026-02-18T17:54:46.381631\",\"recommendations\":[\"u26a0ufe0f u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b\",\"u0641u062du0635 u0634u0627u0645u0644 u0644u0644u062du0627u0644u0629 u0627u0644u0635u062du064au0629\",\"u0645u062au0627u0628u0639u0629 u0637u0628u064au0629 u0645u0633u062au0645u0631u0629\"],\"status\":\"u062eu0637u064au0631\",\"weight_percentile\":1}', 0.92, '2026-02-18 14:54:46'),
(40, 'علا', 'rahaf@admin.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"20\",\"intensity_1_10\":\"5\",\"time_of_day\":\"morning\",\"last_fed_minutes_ago\":null,\"age_months\":\"10\",\"guest_name\":\"u0639u0644u0627\",\"guest_email\":\"rahaf@admin.com\"}', '{\"analysis_timestamp\":\"2026-02-18T17:54:54.673019\",\"confidence\":0.72,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636 u0623u0648 u0627u0644u0645u0644u0627u0628u0633\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u062au0642u0637u0639 u0645u0639 u062au0648u0642u0641u0627u062a\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":6,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.72},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0625u0631u0636u0627u0639 u0627u0644u0637u0641u0644 u0641u0648u0631u0627u064b\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u0645u0646u062au0638u0645 u0648u0645u062au0643u0631u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":7,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0648u062cu0648u062f u0625u0635u0627u0628u0629 u0623u0648 u062du0631u0627u0631u0629\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u0628u0643u0627u0621 u062du0627u062f u0648u0645u0633u062au0645u0631\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":9,\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.2}],\"primary_cause\":\"discomfort\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0648u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644.\"}', 0.72, '2026-02-18 14:54:54'),
(41, 'Curran Garza', 'cowanodek@mailinator.com', 'growth_prediction', '{\"age_months\":10,\"weight\":16,\"height\":53,\"gender\":\"male\"}', '{\"age_months\":10,\"average_percentile\":50,\"confidence_score\":0.92,\"current_height\":53,\"current_weight\":16,\"height_percentile\":1,\"message\":\"u0646u0645u0648 u0627u0644u0637u0641u0644 u0636u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a.\",\"prediction_date\":\"2026-02-22T12:29:00.581195\",\"recommendations\":[\"u0627u0644u062du0641u0627u0638 u0639u0644u0649 u062cu062fu0648u0644 u062au063au0630u064au0629 u0645u0646u062au0638u0645\",\"u0645u062au0627u0628u0639u0629 u0645u0631u0627u062du0644 u0627u0644u062au0637u0648u0631\",\"u062au0646u0638u064au0645 u0627u0644u0646u0648u0645\"],\"status\":\"u0637u0628u064au0639u064a\",\"weight_percentile\":99}', 0.92, '2026-02-22 09:29:00'),
(42, 'Erica Oconnor', 'dikil@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"rash\",\"temperature\":\"44\",\"duration_hours\":\"69\",\"age_months\":\"8\",\"guest_name\":\"Erica Oconnor\",\"guest_email\":\"dikil@mailinator.com\"}', '{\"action\":\"u064au0641u0636u0644 u0627u0633u062au0634u0627u0631u0629 u0637u0628u064au0628 u0627u0644u0623u0637u0641u0627u0644 u0644u062au0642u064au064au0645 u0627u0644u062du0627u0644u0629\",\"arabic_name\":\"rash\",\"home_care\":\"u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644 u0648u062au0633u062cu064au0644 u0627u0644u0623u0639u0631u0627u0636\",\"normal_range\":\"u064au062eu062au0644u0641 u062du0633u0628 u0627u0644u0639u0645u0631 u0648u0627u0644u062du0627u0644u0629\"}', NULL, '2026-02-22 09:29:05'),
(43, 'Amanda Sims', 'pahexi@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"70\",\"intensity_1_10\":\"6\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"17\",\"age_months\":\"9\",\"guest_name\":\"Amanda Sims\",\"guest_email\":\"pahexi@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:36:04.589309\",\"confidence\":0.65,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636u060c u0636u0628u0637 u062fu0631u062cu0629 u062du0631u0627u0631u0629 u0627u0644u063au0631u0641u0629u060c u062au0647u062fu0626u0629 u0627u0644u0637u0641u0644.\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u0642u062f u064au0643u0648u0646 u0645u062au0633u062e u0627u0644u062du0641u0627u0636 u0623u0648 u064au0634u0639u0631 u0628u0627u0644u062du0631u0627u0631u0629/u0627u0644u0628u0631u0648u062fu0629.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.65},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0647u062fu0626u0629 u0627u0644u063au0631u0641u0629 u0648u062au0642u0644u064au0644 u0627u0644u0645u062du0641u0632u0627u062a.\",\"u0627u0644u0633u0628u0628\":\"u0641u0631u0637 u062au062du0641u064au0632\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u0645u062au062du0645u0633 u0623u0648 u0645u0646u0628u0647 u0628u0634u0643u0644 u0632u0627u0626u062f.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0648u0641u064au0631 u0628u064au0626u0629 u0647u0627u062fu0626u0629 u0648u0645u0638u0644u0645u0629 u0644u0644u0646u0648u0645.\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628/u0646u0639u0627u0633\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u064au0634u0639u0631 u0628u0627u0644u0646u0639u0627u0633 u0623u0648 u0628u062du0627u062cu0629 u0644u0644u0646u0648u0645.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.5}],\"primary_cause\":\"discomfort\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.65, '2026-02-22 09:36:04'),
(44, 'Amanda Sims', 'pahexi@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"70\",\"intensity_1_10\":\"6\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"17\",\"age_months\":\"9\",\"guest_name\":\"Amanda Sims\",\"guest_email\":\"pahexi@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:42:24.757127\",\"confidence\":0.65,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636u060c u0636u0628u0637 u062fu0631u062cu0629 u062du0631u0627u0631u0629 u0627u0644u063au0631u0641u0629u060c u062au0647u062fu0626u0629 u0627u0644u0637u0641u0644.\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u0642u062f u064au0643u0648u0646 u0645u062au0633u062e u0627u0644u062du0641u0627u0636 u0623u0648 u064au0634u0639u0631 u0628u0627u0644u062du0631u0627u0631u0629/u0627u0644u0628u0631u0648u062fu0629.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.65},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0647u062fu0626u0629 u0627u0644u063au0631u0641u0629 u0648u062au0642u0644u064au0644 u0627u0644u0645u062du0641u0632u0627u062a.\",\"u0627u0644u0633u0628u0628\":\"u0641u0631u0637 u062au062du0641u064au0632\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u0645u062au062du0645u0633 u0623u0648 u0645u0646u0628u0647 u0628u0634u0643u0644 u0632u0627u0626u062f.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0648u0641u064au0631 u0628u064au0626u0629 u0647u0627u062fu0626u0629 u0648u0645u0638u0644u0645u0629 u0644u0644u0646u0648u0645.\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628/u0646u0639u0627u0633\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u064au0634u0639u0631 u0628u0627u0644u0646u0639u0627u0633 u0623u0648 u0628u062du0627u062cu0629 u0644u0644u0646u0648u0645.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.5}],\"primary_cause\":\"discomfort\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.65, '2026-02-22 09:42:24'),
(45, 'Leonard Marsh', 'biwuvijy@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"45\",\"intensity_1_10\":\"10\",\"time_of_day\":\"night\",\"last_fed_minutes_ago\":\"21\",\"age_months\":\"11\",\"guest_name\":\"Leonard Marsh\",\"guest_email\":\"biwuvijy@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:42:41.773085\",\"confidence\":0.6,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0627u0633u062au0645u0631 u0627u0644u0623u0644u0645.\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0628u0643u0627u0621 u062du0627u062f u0648u0645u0635u0627u062du0628 u0628u0623u0639u0631u0627u0636 u0623u0644u0645.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0639u0627u0644u064a\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0648u0641u064au0631 u0628u064au0626u0629 u0647u0627u062fu0626u0629 u0648u0645u0638u0644u0645u0629 u0644u0644u0646u0648u0645.\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628/u0646u0639u0627u0633\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u064au0634u0639u0631 u0628u0627u0644u0646u0639u0627u0633 u0623u0648 u0628u062du0627u062cu0629 u0644u0644u0646u0648u0645.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.5},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636u060c u0636u0628u0637 u062fu0631u062cu0629 u062du0631u0627u0631u0629 u0627u0644u063au0631u0641u0629u060c u062au0647u062fu0626u0629 u0627u0644u0637u0641u0644.\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u0642u062f u064au0643u0648u0646 u0645u062au0633u062e u0627u0644u062du0641u0627u0636 u0623u0648 u064au0634u0639u0631 u0628u0627u0644u062du0631u0627u0631u0629/u0627u0644u0628u0631u0648u062fu0629.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"pain\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.6, '2026-02-22 09:42:41');
INSERT INTO `guest_ai_analysis` (`id`, `guest_name`, `guest_email`, `analysis_type`, `input_data`, `ai_result`, `confidence_score`, `created_at`) VALUES
(46, 'Leonard Marsh', 'biwuvijy@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"45\",\"intensity_1_10\":\"10\",\"time_of_day\":\"night\",\"last_fed_minutes_ago\":\"21\",\"age_months\":\"11\",\"guest_name\":\"Leonard Marsh\",\"guest_email\":\"biwuvijy@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:43:41.993907\",\"confidence\":0.6,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0627u0633u062au0645u0631 u0627u0644u0623u0644u0645.\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0628u0643u0627u0621 u062du0627u062f u0648u0645u0635u0627u062du0628 u0628u0623u0639u0631u0627u0636 u0623u0644u0645.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0639u0627u0644u064a\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0648u0641u064au0631 u0628u064au0626u0629 u0647u0627u062fu0626u0629 u0648u0645u0638u0644u0645u0629 u0644u0644u0646u0648u0645.\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628/u0646u0639u0627u0633\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u064au0634u0639u0631 u0628u0627u0644u0646u0639u0627u0633 u0623u0648 u0628u062du0627u062cu0629 u0644u0644u0646u0648u0645.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.5},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636u060c u0636u0628u0637 u062fu0631u062cu0629 u062du0631u0627u0631u0629 u0627u0644u063au0631u0641u0629u060c u062au0647u062fu0626u0629 u0627u0644u0637u0641u0644.\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u0642u062f u064au0643u0648u0646 u0645u062au0633u062e u0627u0644u062du0641u0627u0636 u0623u0648 u064au0634u0639u0631 u0628u0627u0644u062du0631u0627u0631u0629/u0627u0644u0628u0631u0648u062fu0629.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"pain\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.6, '2026-02-22 09:43:41'),
(47, 'Leonard Marsh', 'biwuvijy@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"45\",\"intensity_1_10\":\"10\",\"time_of_day\":\"night\",\"last_fed_minutes_ago\":\"21\",\"age_months\":\"11\",\"guest_name\":\"Leonard Marsh\",\"guest_email\":\"biwuvijy@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:44:35.953496\",\"confidence\":0.6,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"pain\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"tired\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.5},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"discomfort\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"pain\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.6, '2026-02-22 09:44:35'),
(48, 'Leonard Marsh', 'biwuvijy@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"45\",\"intensity_1_10\":\"10\",\"time_of_day\":\"night\",\"last_fed_minutes_ago\":\"21\",\"age_months\":\"11\",\"guest_name\":\"Leonard Marsh\",\"guest_email\":\"biwuvijy@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:44:43.986538\",\"confidence\":0.6,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"pain\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"tired\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.5},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"discomfort\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"pain\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.6, '2026-02-22 09:44:43'),
(49, 'Hilary Rice', 'xawidix@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"63\",\"intensity_1_10\":\"2\",\"time_of_day\":\"morning\",\"last_fed_minutes_ago\":\"13\",\"age_months\":\"7\",\"guest_name\":\"Hilary Rice\",\"guest_email\":\"xawidix@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:44:54.644822\",\"confidence\":0.6,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"tired\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"discomfort\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"pain\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.2}],\"primary_cause\":\"tired\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.6, '2026-02-22 09:44:54'),
(50, 'Dorian Mathews', 'xapocup@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"22\",\"intensity_1_10\":\"9\",\"time_of_day\":\"afternoon\",\"last_fed_minutes_ago\":\"88\",\"age_months\":\"5\",\"guest_name\":\"Dorian Mathews\",\"guest_email\":\"xapocup@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:45:39.977483\",\"confidence\":0.6,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0627u0633u062au0645u0631 u0627u0644u0623u0644u0645.\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0628u0643u0627u0621 u062du0627u062f u0648u0645u0635u0627u062du0628 u0628u0623u0639u0631u0627u0636 u0623u0644u0645.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0639u0627u0644u064a\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0641u0642u062f u0627u0644u062du0641u0627u0636u060c u0636u0628u0637 u062fu0631u062cu0629 u062du0631u0627u0631u0629 u0627u0644u063au0631u0641u0629u060c u062au0647u062fu0626u0629 u0627u0644u0637u0641u0644.\",\"u0627u0644u0633u0628u0628\":\"u0627u0646u0632u0639u0627u062c\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u0642u062f u064au0643u0648u0646 u0645u062au0633u062e u0627u0644u062du0641u0627u0636 u0623u0648 u064au0634u0639u0631 u0628u0627u0644u062du0631u0627u0631u0629/u0627u0644u0628u0631u0648u062fu0629.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u062au0648u0641u064au0631 u0628u064au0626u0629 u0647u0627u062fu0626u0629 u0648u0645u0638u0644u0645u0629 u0644u0644u0646u0648u0645.\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628/u0646u0639u0627u0633\",\"u0627u0644u0648u0635u0641\":\"u0627u0644u0637u0641u0644 u064au0634u0639u0631 u0628u0627u0644u0646u0639u0627u0633 u0623u0648 u0628u062du0627u062cu0629 u0644u0644u0646u0648u0645.\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u062eu0641u064au0641\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"pain\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.6, '2026-02-22 09:45:39'),
(51, 'Dorian Mathews', 'xapocup@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"22\",\"intensity_1_10\":\"9\",\"time_of_day\":\"afternoon\",\"last_fed_minutes_ago\":\"88\",\"age_months\":\"5\",\"guest_name\":\"Dorian Mathews\",\"guest_email\":\"xapocup@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:47:45.707736\",\"confidence\":0.6,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.6},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0639u062fu0645 u0627u0631u062au064au0627u062d\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"u0623u0644u0645\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.6, '2026-02-22 09:47:45'),
(52, 'علا', 'rahaf@admin.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"300\",\"intensity_1_10\":\"3\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"200\",\"age_months\":\"2\",\"guest_name\":\"u0639u0644u0627\",\"guest_email\":\"rahaf@admin.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:50:06.976142\",\"confidence\":0.89,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.89},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.8},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0639u062fu0645 u0627u0631u062au064au0627u062d\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"u062cu0648u0639\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.89, '2026-02-22 09:50:06'),
(53, 'Hedda May', 'lelaguqug@mailinator.com', 'growth_prediction', '{\"age_months\":6,\"weight\":8.5,\"height\":68,\"gender\":\"male\"}', '{\"age_months\":6,\"average_percentile\":76.97,\"confidence_score\":0.92,\"current_height\":68,\"current_weight\":8.5,\"height_percentile\":54.93,\"message\":\"u0646u0645u0648 u0627u0644u0637u0641u0644 u0636u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a.\",\"prediction_date\":\"2026-02-22T12:51:09.980961\",\"recommendations\":[\"u0627u0644u062du0641u0627u0638 u0639u0644u0649 u062cu062fu0648u0644 u062au063au0630u064au0629 u0645u0646u062au0638u0645\",\"u0645u062au0627u0628u0639u0629 u0645u0631u0627u062du0644 u0627u0644u062au0637u0648u0631\",\"u062au0646u0638u064au0645 u0627u0644u0646u0648u0645\"],\"status\":\"u0637u0628u064au0639u064a\",\"weight_percentile\":99}', 0.92, '2026-02-22 09:51:09'),
(54, 'Hedda May', 'lelaguqug@mailinator.com', 'growth_prediction', '{\"age_months\":12,\"weight\":8,\"height\":70,\"gender\":\"female\"}', '{\"age_months\":12,\"average_percentile\":6.2,\"confidence_score\":0.92,\"current_height\":70,\"current_weight\":8,\"height_percentile\":11.4,\"message\":\"u26a0ufe0f u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0642u0644u0642.\",\"prediction_date\":\"2026-02-22T12:52:15.480704\",\"recommendations\":[\"u26a0ufe0f u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b\",\"u0641u062du0635 u0634u0627u0645u0644 u0644u0644u062du0627u0644u0629 u0627u0644u0635u062du064au0629\",\"u0645u062au0627u0628u0639u0629 u0637u0628u064au0629 u0645u0633u062au0645u0631u0629\"],\"status\":\"u062eu0637u064au0631\",\"weight_percentile\":1}', 0.92, '2026-02-22 09:52:15'),
(55, 'Hedda May', 'lelaguqug@mailinator.com', 'growth_prediction', '{\"age_months\":24,\"weight\":16,\"height\":95,\"gender\":\"female\"}', '{\"age_months\":24,\"average_percentile\":99,\"confidence_score\":0.92,\"current_height\":95,\"current_weight\":16,\"height_percentile\":99,\"message\":\"u0627u0644u0646u0645u0648 u0623u0639u0644u0649 u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0644u062du0648u0638.\",\"prediction_date\":\"2026-02-22T12:53:31.470933\",\"recommendations\":[\"u0645u0631u0627u0642u0628u0629 u0627u0644u0646u0638u0627u0645 u0627u0644u063au0630u0627u0626u064a\",\"u062au062cu0646u0628 u0627u0644u0625u0641u0631u0627u0637 u0641u064a u0627u0644u062au063au0630u064au0629\",\"u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0644u062au0642u064au064au0645 u0627u0644u0646u0645u0648\"],\"status\":\"u0645u0631u062au0641u0639_u062cu062fu0627u064b\",\"weight_percentile\":99}', 0.92, '2026-02-22 09:53:31'),
(56, 'علا', 'rahaf@admin.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"1200\",\"intensity_1_10\":\"9\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"60\",\"age_months\":\"2\",\"guest_name\":\"u0639u0644u0627\",\"guest_email\":\"rahaf@admin.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:55:21.294885\",\"confidence\":0.85,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.85},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0641u0631u0637 u062au062du0641u064au0632\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.5},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.4}],\"primary_cause\":\"u0623u0644u0645\",\"urgent_recommendation\":\"u26a0ufe0f u0628u0643u0627u0621 u0634u062fu064au062f u062cu062fu0627u064b u0648u0645u0645u062au062f u2014 u064au0641u0636u0644 u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b.\"}', 0.85, '2026-02-22 09:55:21'),
(57, 'علا', 'rahaf@admin.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"200\",\"intensity_1_10\":\"3\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"30\",\"age_months\":\"6\",\"guest_name\":\"u0639u0644u0627\",\"guest_email\":\"rahaf@admin.com\"}', '{\"analysis_timestamp\":\"2026-02-22T12:56:13.518302\",\"confidence\":0.8,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.8},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.42},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0639u062fu0645 u0627u0631u062au064au0627u062d\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"u062au0639u0628\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.8, '2026-02-22 09:56:13'),
(58, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"37.5\",\"duration_hours\":\"2\",\"age_months\":\"6\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 09:57:35'),
(59, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 09:58:27'),
(60, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 09:58:31'),
(61, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 09:58:44'),
(62, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 09:58:52'),
(63, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"20\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 09:59:00'),
(64, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"20\",\"age_months\":\"6\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 09:59:04'),
(65, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"20\",\"age_months\":\"6\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:03:10'),
(66, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"20\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:03:19'),
(67, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:03:28'),
(68, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:03:44'),
(69, 'Hedda May', 'lelaguqug@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:04:28'),
(70, 'Quon Copeland', 'ganuqigo@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Quon Copeland\",\"guest_email\":\"ganuqigo@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:05:20'),
(71, 'Quon Copeland', 'ganuqigo@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Quon Copeland\",\"guest_email\":\"ganuqigo@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:06:50'),
(72, 'Eve Foley', 'lufylebywo@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Eve Foley\",\"guest_email\":\"lufylebywo@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:07:07'),
(73, 'Eve Foley', 'lufylebywo@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Eve Foley\",\"guest_email\":\"lufylebywo@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:08:12'),
(74, 'Eve Foley', 'lufylebywo@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Eve Foley\",\"guest_email\":\"lufylebywo@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:09:08'),
(75, 'Eve Foley', 'lufylebywo@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Eve Foley\",\"guest_email\":\"lufylebywo@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:10:45'),
(76, 'Eve Foley', 'lufylebywo@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Eve Foley\",\"guest_email\":\"lufylebywo@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:12:17'),
(77, 'Amy Ward', 'mamogajype@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Amy Ward\",\"guest_email\":\"mamogajype@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:12:33'),
(78, 'Amy Ward', 'mamogajype@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Amy Ward\",\"guest_email\":\"mamogajype@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:12:46'),
(79, 'Amy Ward', 'mamogajype@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"cough\",\"temperature\":\"39.5\",\"duration_hours\":\"5\",\"age_months\":\"2\",\"guest_name\":\"Amy Ward\",\"guest_email\":\"mamogajype@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u0643u0627u0646 u0634u062fu064au062fu0627u064b u0623u0648 u0645u0639 u0635u0639u0648u0628u0629 u062au0646u0641u0633\",\"arabic_name\":\"u0633u0639u0627u0644\",\"home_care\":\"u062cu0647u0627u0632 u062au0631u0637u064au0628u060c u0633u0648u0627u0626u0644 u062fu0627u0641u0626u0629\",\"normal_range\":\"u0627u0644u0633u0639u0627u0644 u0627u0644u062eu0641u064au0641 u0637u0628u064au0639u064a\"}', NULL, '2026-02-22 10:12:52'),
(80, 'Alan Lester', 'sulojekeli@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"37\",\"duration_hours\":\"47\",\"age_months\":\"5\",\"guest_name\":\"Alan Lester\",\"guest_email\":\"sulojekeli@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:13:01'),
(81, 'Alan Lester', 'sulojekeli@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"rash\",\"temperature\":\"37\",\"duration_hours\":\"47\",\"age_months\":\"5\",\"guest_name\":\"Alan Lester\",\"guest_email\":\"sulojekeli@mailinator.com\"}', '{\"action\":\"u064au0641u0636u0644 u0627u0633u062au0634u0627u0631u0629 u0637u0628u064au0628 u0627u0644u0623u0637u0641u0627u0644 u0644u062au0642u064au064au0645 u0627u0644u062du0627u0644u0629\",\"arabic_name\":\"rash\",\"home_care\":\"u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644 u0648u062au0633u062cu064au0644 u0627u0644u0623u0639u0631u0627u0636\",\"normal_range\":\"u064au062eu062au0644u0641 u062du0633u0628 u0627u0644u0639u0645u0631 u0648u0627u0644u062du0627u0644u0629\"}', NULL, '2026-02-22 10:13:05'),
(82, 'Alan Lester', 'sulojekeli@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"rash\",\"temperature\":\"37\",\"duration_hours\":\"47\",\"age_months\":\"5\",\"guest_name\":\"Alan Lester\",\"guest_email\":\"sulojekeli@mailinator.com\"}', '{\"action\":\"u064au0641u0636u0644 u0627u0633u062au0634u0627u0631u0629 u0637u0628u064au0628 u0627u0644u0623u0637u0641u0627u0644 u0644u062au0642u064au064au0645 u0627u0644u062du0627u0644u0629\",\"arabic_name\":\"rash\",\"home_care\":\"u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644 u0648u062au0633u062cu064au0644 u0627u0644u0623u0639u0631u0627u0636\",\"normal_range\":\"u064au062eu062au0644u0641 u062du0633u0628 u0627u0644u0639u0645u0631 u0648u0627u0644u062du0627u0644u0629\"}', NULL, '2026-02-22 10:14:15'),
(83, 'Alan Lester', 'sulojekeli@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"rash\",\"temperature\":\"37\",\"duration_hours\":\"47\",\"age_months\":\"5\",\"guest_name\":\"Alan Lester\",\"guest_email\":\"sulojekeli@mailinator.com\"}', '{\"action\":\"u064au0641u0636u0644 u0627u0633u062au0634u0627u0631u0629 u0637u0628u064au0628 u0627u0644u0623u0637u0641u0627u0644 u0644u062au0642u064au064au0645 u0627u0644u062du0627u0644u0629\",\"arabic_name\":\"rash\",\"home_care\":\"u0645u0631u0627u0642u0628u0629 u0627u0644u0637u0641u0644 u0648u062au0633u062cu064au0644 u0627u0644u0623u0639u0631u0627u0636\",\"normal_range\":\"u064au062eu062au0644u0641 u062du0633u0628 u0627u0644u0639u0645u0631 u0648u0627u0644u062du0627u0644u0629\"}', NULL, '2026-02-22 10:14:21'),
(84, 'Hector Arnold', 'mufidet@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"diarrhea\",\"temperature\":\"23\",\"duration_hours\":\"56\",\"age_months\":\"2\",\"guest_name\":\"Hector Arnold\",\"guest_email\":\"mufidet@mailinator.com\"}', '{\"action\":\"u0631u0627u062cu0639 u0627u0644u0637u0628u064au0628 u0639u0646u062f u0638u0647u0648u0631 u062cu0641u0627u0641\",\"arabic_name\":\"u0625u0633u0647u0627u0644\",\"home_care\":\"u0627u0644u0627u0633u062au0645u0631u0627u0631 u0641u064a u0627u0644u0631u0636u0627u0639u0629\",\"normal_range\":\"u0627u0644u0628u0631u0627u0632 u0627u0644u0631u062eu0648 u0634u0627u0626u0639 u0639u0646u062f u0627u0644u0631u0636u0639\"}', NULL, '2026-02-22 10:14:27'),
(85, 'Hector Arnold', 'mufidet@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"diarrhea\",\"temperature\":\"23\",\"duration_hours\":\"56\",\"age_months\":\"3\",\"guest_name\":\"Hector Arnold\",\"guest_email\":\"mufidet@mailinator.com\"}', '{\"action\":\"u0631u0627u062cu0639 u0627u0644u0637u0628u064au0628 u0639u0646u062f u0638u0647u0648u0631 u062cu0641u0627u0641\",\"arabic_name\":\"u0625u0633u0647u0627u0644\",\"home_care\":\"u0627u0644u0627u0633u062au0645u0631u0627u0631 u0641u064a u0627u0644u0631u0636u0627u0639u0629\",\"normal_range\":\"u0627u0644u0628u0631u0627u0632 u0627u0644u0631u062eu0648 u0634u0627u0626u0639 u0639u0646u062f u0627u0644u0631u0636u0639\"}', NULL, '2026-02-22 10:14:54'),
(86, 'Hector Arnold', 'mufidet@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"diarrhea\",\"temperature\":\"40\",\"duration_hours\":\"56\",\"age_months\":\"3\",\"guest_name\":\"Hector Arnold\",\"guest_email\":\"mufidet@mailinator.com\"}', '{\"action\":\"u0631u0627u062cu0639 u0627u0644u0637u0628u064au0628 u0639u0646u062f u0638u0647u0648u0631 u062cu0641u0627u0641\",\"arabic_name\":\"u0625u0633u0647u0627u0644\",\"home_care\":\"u0627u0644u0627u0633u062au0645u0631u0627u0631 u0641u064a u0627u0644u0631u0636u0627u0639u0629\",\"normal_range\":\"u0627u0644u0628u0631u0627u0632 u0627u0644u0631u062eu0648 u0634u0627u0626u0639 u0639u0646u062f u0627u0644u0631u0636u0639\"}', NULL, '2026-02-22 10:15:01'),
(87, 'Hector Arnold', 'mufidet@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"fever\",\"temperature\":\"40\",\"duration_hours\":\"5\",\"age_months\":\"3\",\"guest_name\":\"Hector Arnold\",\"guest_email\":\"mufidet@mailinator.com\"}', '{\"action\":\"u0627u0633u062au0634u0631 u0627u0644u0637u0628u064au0628 u0625u0630u0627 u062au062cu0627u0648u0632u062a 38.5u00b0u0645 u0623u0648 u0627u0633u062au0645u0631u062a u0623u0643u062bu0631 u0645u0646 3 u0623u064au0627u0645\",\"arabic_name\":\"u062du0645u0649\",\"home_care\":\"u0645u0644u0627u0628u0633 u062eu0641u064au0641u0629u060c u0633u0648u0627u0626u0644 u0643u0627u0641u064au0629u060c u0645u0631u0627u0642u0628u0629 u0627u0644u062du0631u0627u0631u0629\",\"normal_range\":\"36.5 - 37.5u00b0u0645\"}', NULL, '2026-02-22 10:15:08'),
(88, 'Hedda May', 'sesycilu@mailinator.com', 'growth_prediction', '{\"age_months\":6,\"weight\":8.5,\"height\":68,\"gender\":\"male\"}', '{\"age_months\":6,\"average_percentile\":76.97,\"confidence_score\":0.92,\"current_height\":68,\"current_weight\":8.5,\"height_percentile\":54.93,\"message\":\"u0646u0645u0648 u0627u0644u0637u0641u0644 u0636u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a.\",\"prediction_date\":\"2026-02-22T13:20:38.428220\",\"recommendations\":[\"u0627u0644u062du0641u0627u0638 u0639u0644u0649 u062cu062fu0648u0644 u062au063au0630u064au0629 u0645u0646u062au0638u0645\",\"u0645u062au0627u0628u0639u0629 u0645u0631u0627u062du0644 u0627u0644u062au0637u0648u0631\",\"u062au0646u0638u064au0645 u0627u0644u0646u0648u0645\"],\"status\":\"u0637u0628u064au0639u064a\",\"weight_percentile\":99}', 0.92, '2026-02-22 10:20:38'),
(89, 'Hedda May', 'sesycilu@mailinator.com', 'growth_prediction', '{\"age_months\":12,\"weight\":8,\"height\":70,\"gender\":\"female\"}', '{\"age_months\":12,\"average_percentile\":6.2,\"confidence_score\":0.92,\"current_height\":70,\"current_weight\":8,\"height_percentile\":11.4,\"message\":\"u26a0ufe0f u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0642u0644u0642.\",\"prediction_date\":\"2026-02-22T13:21:05.042254\",\"recommendations\":[\"u26a0ufe0f u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b\",\"u0641u062du0635 u0634u0627u0645u0644 u0644u0644u062du0627u0644u0629 u0627u0644u0635u062du064au0629\",\"u0645u062au0627u0628u0639u0629 u0637u0628u064au0629 u0645u0633u062au0645u0631u0629\"],\"status\":\"u062eu0637u064au0631\",\"weight_percentile\":1}', 0.92, '2026-02-22 10:21:05'),
(90, 'Hedda May', 'sesycilu@mailinator.com', 'growth_prediction', '{\"age_months\":24,\"weight\":16,\"height\":95,\"gender\":\"male\"}', '{\"age_months\":24,\"average_percentile\":99,\"confidence_score\":0.92,\"current_height\":95,\"current_weight\":16,\"height_percentile\":99,\"message\":\"u0627u0644u0646u0645u0648 u0623u0639u0644u0649 u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a u0628u0634u0643u0644 u0645u0644u062du0648u0638.\",\"prediction_date\":\"2026-02-22T13:21:47.935728\",\"recommendations\":[\"u0645u0631u0627u0642u0628u0629 u0627u0644u0646u0638u0627u0645 u0627u0644u063au0630u0627u0626u064a\",\"u062au062cu0646u0628 u0627u0644u0625u0641u0631u0627u0637 u0641u064a u0627u0644u062au063au0630u064au0629\",\"u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0644u062au0642u064au064au0645 u0627u0644u0646u0645u0648\"],\"status\":\"u0645u0631u062au0641u0639_u062cu062fu0627u064b\",\"weight_percentile\":99}', 0.92, '2026-02-22 10:21:47');
INSERT INTO `guest_ai_analysis` (`id`, `guest_name`, `guest_email`, `analysis_type`, `input_data`, `ai_result`, `confidence_score`, `created_at`) VALUES
(91, 'Hedda May', 'lelaguqug@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"300\",\"intensity_1_10\":\"3\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"200\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T13:22:34.955003\",\"confidence\":0.89,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.89},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.8},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0639u062fu0645 u0627u0631u062au064au0627u062d\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"u062cu0648u0639\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.89, '2026-02-22 10:22:34'),
(92, 'Hedda May', 'lelaguqug@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"1200\",\"intensity_1_10\":\"9\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"60\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T13:23:16.174408\",\"confidence\":0.85,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0623u0644u0645\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.85},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0641u0631u0637 u062au062du0641u064au0632\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.5},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.4}],\"primary_cause\":\"u0623u0644u0645\",\"urgent_recommendation\":\"u26a0ufe0f u0628u0643u0627u0621 u0634u062fu064au062f u062cu062fu0627u064b u0648u0645u0645u062au062f u2014 u064au0641u0636u0644 u0645u0631u0627u062cu0639u0629 u0627u0644u0637u0628u064au0628 u0641u0648u0631u0627u064b.\"}', 0.85, '2026-02-22 10:23:16'),
(93, 'Hedda May', 'lelaguqug@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"200\",\"intensity_1_10\":\"3\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"30\",\"age_months\":\"6\",\"guest_name\":\"Hedda May\",\"guest_email\":\"lelaguqug@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-02-22T13:23:43.771512\",\"confidence\":0.8,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.8},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.42},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0639u062fu0645 u0627u0631u062au064au0627u062d\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"u062au0639u0628\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.8, '2026-02-22 10:23:43'),
(94, 'Erica Oconnor', 'olafatnah68@gmail.com', 'growth_prediction', '{\"age_months\":2,\"weight\":10,\"height\":40,\"gender\":\"male\"}', '{\"age_months\":2,\"average_percentile\":50,\"confidence_score\":0.92,\"current_height\":40,\"current_weight\":10,\"height_percentile\":1,\"message\":\"u0646u0645u0648 u0627u0644u0637u0641u0644 u0636u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a.\",\"prediction_date\":\"2026-03-09T12:02:38.199075\",\"recommendations\":[\"u0627u0644u062du0641u0627u0638 u0639u0644u0649 u062cu062fu0648u0644 u062au063au0630u064au0629 u0645u0646u062au0638u0645\",\"u0645u062au0627u0628u0639u0629 u0645u0631u0627u062du0644 u0627u0644u062au0637u0648u0631\",\"u062au0646u0638u064au0645 u0627u0644u0646u0648u0645\"],\"status\":\"u0637u0628u064au0639u064a\",\"weight_percentile\":99}', 0.92, '2026-03-09 09:02:38'),
(95, 'Wesley Buckner', 'gumypyfic@mailinator.com', 'symptom_check', '{\"action\":\"symptom_guidance\",\"symptom\":\"diarrhea\",\"temperature\":\"14\",\"duration_hours\":\"49\",\"age_months\":\"5\",\"guest_name\":\"Wesley Buckner\",\"guest_email\":\"gumypyfic@mailinator.com\"}', '{\"action\":\"u0631u0627u062cu0639 u0627u0644u0637u0628u064au0628 u0639u0646u062f u0638u0647u0648u0631 u062cu0641u0627u0641\",\"arabic_name\":\"u0625u0633u0647u0627u0644\",\"home_care\":\"u0627u0644u0627u0633u062au0645u0631u0627u0631 u0641u064a u0627u0644u0631u0636u0627u0639u0629\",\"normal_range\":\"u0627u0644u0628u0631u0627u0632 u0627u0644u0631u062eu0648 u0634u0627u0626u0639 u0639u0646u062f u0627u0644u0631u0636u0639\"}', NULL, '2026-03-09 09:03:05'),
(96, 'علا', 'sesycilu@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"300\",\"intensity_1_10\":\"4\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"199\",\"age_months\":\"2\",\"guest_name\":\"u0639u0644u0627\",\"guest_email\":\"sesycilu@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-03-09T12:06:57.360178\",\"confidence\":0.88,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.88},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.8},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0639u062fu0645 u0627u0631u062au064au0627u062d\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.65}],\"primary_cause\":\"u062cu0648u0639\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.88, '2026-03-09 09:06:57'),
(97, 'Hedda May', 'sesycilu@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"200\",\"intensity_1_10\":\"3\",\"time_of_day\":\"evening\",\"last_fed_minutes_ago\":\"199\",\"age_months\":\"2\",\"guest_name\":\"Hedda May\",\"guest_email\":\"sesycilu@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-03-09T12:08:32.329540\",\"confidence\":0.88,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.88},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.8},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0639u062fu0645 u0627u0631u062au064au0627u062d\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"u062cu0648u0639\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.88, '2026-03-09 09:08:32'),
(98, 'Alyssa Mercer', 'byjecoqo@mailinator.com', 'growth_prediction', '{\"age_months\":11,\"weight\":3,\"height\":77,\"gender\":\"female\"}', '{\"age_months\":11,\"average_percentile\":45.94,\"confidence_score\":0.92,\"current_height\":77,\"current_weight\":3,\"height_percentile\":90.87,\"message\":\"u0627u0644u0646u0645u0648 u0623u0642u0644 u0645u0646 u0627u0644u0645u062au0648u0633u0637.\",\"prediction_date\":\"2026-03-13T09:50:46.408420\",\"recommendations\":[\"u0632u064au0627u062fu0629 u0627u0644u0633u0639u0631u0627u062a u0627u0644u062du0631u0627u0631u064au0629 u0628u0634u0643u0644 u0635u062du064a\",\"u062au0642u0633u064au0645 u0627u0644u0648u062cu0628u0627u062a u0625u0644u0649 u0643u0645u064au0627u062a u0623u0635u063au0631 u0648u0645u062au0643u0631u0631u0629\",\"u0645u0631u0627u0642u0628u0629 u0627u0644u0648u0632u0646 u0623u0633u0628u0648u0639u064au0627u064b\"],\"status\":\"u0623u0642u0644_u0645u0646_u0627u0644u0645u0639u062fu0644\",\"weight_percentile\":1}', 0.92, '2026-03-13 06:50:46'),
(99, 'Ivor Underwood', 'pyqod@mailinator.com', 'cry_analysis', '{\"action\":\"cry_analysis\",\"duration_seconds\":\"26\",\"intensity_1_10\":\"1\",\"time_of_day\":\"night\",\"last_fed_minutes_ago\":\"51\",\"age_months\":\"1\",\"guest_name\":\"Ivor Underwood\",\"guest_email\":\"pyqod@mailinator.com\"}', '{\"analysis_timestamp\":\"2026-03-13T09:50:49.662642\",\"confidence\":0.8,\"detailed_analysis\":[{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062au0639u0628\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.8},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u062cu0648u0639\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3},{\"u0627u0644u062du0644_u0627u0644u0645u0642u062au0631u062d\":\"u064au0631u062cu0649 u0645u0631u0627u062cu0639u0629 u0627u0644u0645u062eu062au0635\",\"u0627u0644u0633u0628u0628\":\"u0639u062fu0645 u0627u0631u062au064au0627u062d\",\"u0627u0644u0648u0635u0641\":\"u063au064au0631 u0645u062du062fu062f\",\"u0645u0633u062au0648u0649_u0627u0644u0634u062fu0629\":\"u0645u062au0648u0633u0637\",\"u0646u0633u0628u0629_u0627u0644u062bu0642u0629\":0.3}],\"primary_cause\":\"u062au0639u0628\",\"urgent_recommendation\":\"u064au0645u0643u0646 u062au062cu0631u0628u0629 u0627u0644u062du0644u0648u0644 u0627u0644u0645u0642u062au0631u062du0629 u0645u0639 u0645u0631u0627u0642u0628u0629 u0627u0644u062du0627u0644u0629.\"}', 0.8, '2026-03-13 06:50:49'),
(100, 'Aquila Mueller', 'cofi@mailinator.com', 'growth_prediction', '{\"age_months\":5,\"weight\":6,\"height\":97,\"gender\":\"male\"}', '{\"age_months\":5,\"average_percentile\":50,\"confidence_score\":0.92,\"current_height\":97,\"current_weight\":6,\"height_percentile\":99,\"message\":\"u0646u0645u0648 u0627u0644u0637u0641u0644 u0636u0645u0646 u0627u0644u0645u0639u062fu0644 u0627u0644u0637u0628u064au0639u064a.\",\"prediction_date\":\"2026-03-13T12:56:45.304773\",\"recommendations\":[\"u0627u0644u062du0641u0627u0638 u0639u0644u0649 u062cu062fu0648u0644 u062au063au0630u064au0629 u0645u0646u062au0638u0645\",\"u0645u062au0627u0628u0639u0629 u0645u0631u0627u062du0644 u0627u0644u062au0637u0648u0631\",\"u062au0646u0638u064au0645 u0627u0644u0646u0648u0645\"],\"status\":\"u0637u0628u064au0639u064a\",\"weight_percentile\":1}', 0.92, '2026-03-13 09:56:45');

-- --------------------------------------------------------

--
-- بنية الجدول `healthcare_centers`
--

CREATE TABLE `healthcare_centers` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` varchar(100) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `working_hours` varchar(100) DEFAULT NULL,
  `services` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `landing_statistics`
--

CREATE TABLE `landing_statistics` (
  `id` int(11) NOT NULL,
  `stat_key` varchar(50) NOT NULL,
  `stat_value` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `landing_statistics`
--

INSERT INTO `landing_statistics` (`id`, `stat_key`, `stat_value`, `description`, `last_updated`) VALUES
(5, 'عدد_الأطفال_المتابعين', '4', 'إجمالي عدد الأطفال المتابعين حاليًا في النظام', '2026-02-16 12:17:54'),
(6, 'المستخدمون_النشطون', '3', 'عدد الحسابات النشطة للآباء', '2026-02-16 12:17:54'),
(7, 'عدد_اللقاحات', '6', 'إجمالي عدد اللقاحات الممنوحة', '2026-02-16 12:17:54'),
(8, 'النسبة_الصحية', '85', 'نسبة الأطفال ضمن نطاق النمو الصحي', '2026-02-16 12:17:54');

-- --------------------------------------------------------

--
-- بنية الجدول `medical_articles`
--

CREATE TABLE `medical_articles` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `author` varchar(100) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `medical_articles`
--

INSERT INTO `medical_articles` (`id`, `title`, `content`, `author`, `category`, `created_at`) VALUES
(1, 'أهمية التطعيمات في السنوات الأولى', 'التطعيمات تحمي الأطفال من الأمراض الخطيرة...', 'د. أحمد محمد', '0-6', '2023-12-31 21:00:00'),
(2, 'تغذية الطفل في الشهر الأول', 'يحتاج الطفل حديث الولادة إلى حليب الأم فقط...', 'د. فاطمة علي', 'تغذية', '2023-12-31 21:00:00'),
(3, 'Culpa est dolores ', 'Quam est aut illum', 'Dr. Ahmad (Pediatrician)', '6-12', '2026-05-06 17:17:38');

-- --------------------------------------------------------

--
-- بنية الجدول `medical_visits`
--

CREATE TABLE `medical_visits` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `visit_date` datetime NOT NULL,
  `diagnosis` text DEFAULT NULL,
  `prescription` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `report_filename` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `medical_visits`
--

INSERT INTO `medical_visits` (`id`, `child_id`, `doctor_id`, `visit_date`, `diagnosis`, `prescription`, `notes`, `report_filename`, `created_at`) VALUES
(1, 6, 6, '2026-03-23 10:00:00', '?????? ?? ?????', NULL, '????? ???????', NULL, '2026-03-23 20:07:05'),
(2, 7, 6, '2026-03-23 14:00:00', '??????', NULL, '?????? ??????', NULL, '2026-03-23 20:07:05'),
(3, 8, 6, '2026-03-30 11:00:00', 'ممممم', 'لالالالا', 'تااتاتا', NULL, '2026-03-23 20:07:05'),
(4, 6, 6, '1985-06-24 02:03:00', 'Ut quis inventore be', 'Veritatis in volupta', 'Cumque culpa dolor ', NULL, '2026-03-27 09:34:25'),
(6, 6, 6, '1980-05-07 06:45:00', 'Delectus minim pari', 'Quas aperiam quia in', 'Est sit ut ullam m', NULL, '2026-05-06 18:55:25'),
(7, 9, 6, '2003-06-13 20:33:00', 'Sed in eius sapiente', 'Aut ad nostrum quis ', 'Cum iure ea eveniet', NULL, '2026-05-06 18:55:48'),
(8, 9, 6, '2025-08-26 14:34:00', 'Rerum fugiat animi ', 'Illo ullamco aperiam', 'Voluptate ut quia vo', NULL, '2026-05-06 20:02:11'),
(9, 21, 6, '1983-11-16 09:48:00', 'Et lorem provident ', 'Aut quo odio cupidat', 'Enim est nobis itaqu', NULL, '2026-05-06 20:02:29'),
(10, 21, 6, '1983-11-16 09:48:00', 'Et lorem provident ', 'Aut quo odio cupidat', 'Enim est nobis itaqu', NULL, '2026-05-06 20:04:12');

-- --------------------------------------------------------

--
-- بنية الجدول `medications`
--

CREATE TABLE `medications` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `dosage_form` enum('tablet','capsule','syrup','injection','drops','cream','other') NOT NULL,
  `concentration` varchar(100) DEFAULT NULL,
  `category` enum('antibiotic','pain_reliever','antipyretic','vitamin','antihistamine','other') DEFAULT 'other',
  `indications` text DEFAULT NULL,
  `side_effects` text DEFAULT NULL,
  `instructions` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `medications`
--

INSERT INTO `medications` (`id`, `name`, `dosage_form`, `concentration`, `category`, `indications`, `side_effects`, `instructions`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'أموكسيسيلين', 'syrup', '120mg/5ml', 'pain_reliever', 'علاج الالتهابات البكتيرية مثل التهاب الحلق والأذن', 'غثيان، إسهال، طفح جلدي', 'يؤخذ 5 مل 3 مرات يومياً لمدة 7-10 أيام حسب إرشادات الطبيب', 6, '2026-03-23 20:03:55', '2026-03-23 20:58:57'),
(2, 'إيبوبروفين', 'syrup', '125mg/5ml', 'antibiotic', 'تخفيف الآلام والالتهابات والحمى', 'اضطراب المعدة، دوار، صداع', 'يؤخذ 5 مل 3 مرات يومياً لمدة 7-10 أيام مع الطعام', 6, '2026-03-23 20:03:55', '2026-03-23 20:58:57'),
(3, 'باراسيتامول', 'tablet', '250mg', 'antibiotic', 'تخفيف الآلام والحمى', 'نادرة: طفح جلدي، اضطراب المعدة', 'يؤخذ 1 قرص كل 6 ساعات عند الحاجة لتخفيف الحرارة', 6, '2026-03-23 20:03:55', '2026-03-23 20:58:57'),
(4, 'فيتامين D', 'drops', '400 IU/drop', 'vitamin', 'علاج نقص فيتامين D وتقوية العظام', 'غثيان، إمساك', 'يؤخذ مرة واحدة يومياً في الصباح مع الطعام', 6, '2026-03-23 20:03:55', '2026-03-23 20:58:57'),
(5, 'أزيثروميسين', 'syrup', '5mg/5ml', 'antihistamine', 'علاج الالتهابات البكتيرية في الجهاز التنفسي', 'غثيان، إسهال، آلام البطن', 'يؤخذ 5 مل 3 مرات يومياً لمدة اسبوع', 6, '2026-03-23 20:03:55', '2026-03-23 20:59:30'),
(6, 'Omar Perry', 'cream', 'Dolorum iste quis do', 'antibiotic', 'Repudiandae sapiente', 'Aspernatur nemo reru', 'Fugiat iure non qui', 6, '2026-05-06 11:34:04', '2026-05-06 11:34:04'),
(7, 'Ginger Morrow', 'syrup', 'Inventore sit tempo', 'vitamin', 'Pariatur Adipisci eيس', 'Velit dignissimos q', 'Facere tempore et e', 6, '2026-05-06 11:34:17', '2026-05-06 17:26:43'),
(8, 'Alec Hickman', 'drops', 'Quia est deleniti ev', 'antipyretic', 'Iusto quia tenetur e', 'Commodo rerum eiusmo', 'Delectus id velit', 6, '2026-05-06 17:28:36', '2026-05-06 17:28:36'),
(9, 'Zachary Franco', 'tablet', 'Recusandae Sit quia', 'vitamin', 'Recusandae Dolore n', 'Quis corporis volupt', 'Sint est in quo faci', 6, '2026-05-06 17:47:34', '2026-05-06 17:47:34');

-- --------------------------------------------------------

--
-- بنية الجدول `medication_interactions`
--

CREATE TABLE `medication_interactions` (
  `id` int(11) NOT NULL,
  `medication_a_id` int(11) NOT NULL,
  `medication_b_id` int(11) NOT NULL,
  `severity` enum('minor','moderate','major') NOT NULL DEFAULT 'moderate',
  `description` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `medication_interactions`
--

INSERT INTO `medication_interactions` (`id`, `medication_a_id`, `medication_b_id`, `severity`, `description`, `created_at`) VALUES
(1, 1, 2, 'major', 'لا يجب تناول باراسيتامول مع الأموكسيسيلين في نفس الوقت دون استشارة الطبيب لأنه قد يزيد من عبء الكبد', '2026-04-01 06:36:07'),
(2, 2, 5, 'moderate', 'تناول الأموكسيسيلين مع لوراتادين قد يقلل من فعالية الاثنين', '2026-04-01 06:36:07'),
(3, 4, 1, 'minor', 'فيتامين D قد يقلل من امتصاص باراسيتامول قليلاً، تباعد الجرعات ساعتين كافٍ', '2026-04-01 06:36:07'),
(4, 3, 2, 'moderate', 'لا يفضل تناول إريثروميسين مع أموكسيسيلين معاً لأنها أدوية متشابهة تماماً', '2026-04-01 06:36:07');

-- --------------------------------------------------------

--
-- بنية الجدول `messages`
--

CREATE TABLE `messages` (
  `id` int(11) NOT NULL,
  `sender_id` int(11) NOT NULL,
  `recipient_id` int(11) DEFAULT NULL,
  `child_id` int(11) DEFAULT NULL,
  `message` text NOT NULL,
  `message_type` enum('general','consultation','urgent') DEFAULT 'general',
  `status` enum('pending','responded','closed') DEFAULT 'pending',
  `response` text DEFAULT NULL,
  `response_date` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `messages`
--

INSERT INTO `messages` (`id`, `sender_id`, `recipient_id`, `child_id`, `message`, `message_type`, `status`, `response`, `response_date`, `created_at`) VALUES
(1, 5, 6, 1, 'طفلي يعاني من ارتفاع في درجة الحرارة', 'consultation', 'responded', NULL, NULL, '2026-03-23 20:06:27'),
(2, 8, 6, 2, 'الطفل يعاني من ألم في البطن منذ يومين، يرجى التوجيه', 'consultation', 'responded', NULL, NULL, '2026-03-23 20:06:27'),
(3, 5, 6, 6, 'طفلتي تعاني من وجع في اسنانها', 'consultation', 'responded', NULL, NULL, '2026-03-26 18:05:08'),
(4, 6, 5, NULL, 'السبب بدأ ظهور الاسنان', 'general', 'responded', NULL, NULL, '2026-03-26 18:06:24'),
(5, 5, 6, 7, 'يسيسي', 'general', 'responded', NULL, NULL, '2026-03-26 18:15:21'),
(6, 6, 5, 7, 'jkjkj', 'general', 'pending', NULL, NULL, '2026-05-06 18:56:23');

-- --------------------------------------------------------

--
-- بنية الجدول `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('info','warning','error','success') DEFAULT 'info',
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `prescription_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title`, `message`, `type`, `is_read`, `created_at`, `prescription_id`) VALUES
(1, 5, 'تذكير تطعيم متأخر', 'طفلك youssef mohammed متأخر عن لقاح شلل الأطفال الفموي (OPV) - جرعة 1 (الموعد: 2025-05-10)', 'warning', 0, '2026-03-11 13:38:22', NULL),
(2, 5, 'تذكير تطعيم متأخر', 'طفلك youssef mohammed متأخر عن لقاح شلل الأطفال الفموي (OPV) - جرعة 1 (الموعد: 2025-05-10)', 'warning', 0, '2026-03-11 13:38:32', NULL),
(3, 5, 'تذكير تطعيم متأخر', 'طفلك youssef mohammed متأخر عن لقاح شلل الأطفال الفموي (OPV) - جرعة 1 (الموعد: 2025-05-10)', 'warning', 0, '2026-03-11 13:42:07', NULL),
(4, 5, 'تذكير تطعيم متأخر', 'طفلك ayla said متأخر عن لقاح الروتا (Rota) - جرعة 2 (الموعد: 2025-10-01)', 'warning', 0, '2026-03-11 13:43:40', NULL),
(5, 5, 'تذكير تطعيم متأخر', 'طفلك ayla said متأخر عن لقاح الروتا (Rota) - جرعة 2 (الموعد: 2025-10-01)', 'warning', 0, '2026-03-11 13:51:55', NULL),
(6, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-03-23 21:06:51', NULL),
(7, 5, 'مرحلة نمو جديدة للطفل ayla said', 'مرحلة نمو مهمة: الشهر التاسع - الوقوف والمشي', 'success', 0, '2026-03-23 21:08:03', NULL),
(8, 5, 'مرحلة نمو جديدة للطفل youssef mohammed', 'مرحلة نمو مهمة: السنة الأولى - الكلام واللعب', 'success', 0, '2026-03-23 21:08:03', NULL),
(9, 5, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل ayla said', 'warning', 0, '2026-03-23 21:08:03', NULL),
(10, 5, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل youssef mohammed', 'warning', 0, '2026-03-23 21:08:03', NULL),
(11, 8, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل laila ahmad', 'warning', 0, '2026-03-23 21:08:03', NULL),
(12, 8, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل ali ahmad', 'warning', 0, '2026-03-23 21:08:03', NULL),
(13, 9, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل Julian Gallegos', 'warning', 0, '2026-03-23 21:08:03', NULL),
(14, 6, 'رسالة جديدة من rama alhoshan (Parent)', 'لديك رسالة جديدة في نظام الدردشة', 'info', 0, '2026-03-26 18:05:08', NULL),
(15, 5, 'رسالة جديدة من Dr. Ahmad (Pediatrician)', 'لديك رسالة جديدة من الطبيب', 'info', 0, '2026-03-26 18:06:24', NULL),
(16, 6, 'رسالة جديدة من rama alhoshan (Parent)', 'لديك رسالة جديدة في نظام الدردشة', 'info', 0, '2026-03-26 18:15:21', NULL),
(17, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-03-27 10:32:43', NULL),
(18, 5, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل ayla said', 'warning', 0, '2026-03-27 10:32:43', NULL),
(19, 5, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل youssef mohammed', 'warning', 0, '2026-03-27 10:32:43', NULL),
(20, 8, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل laila ahmad', 'warning', 0, '2026-03-27 10:32:43', NULL),
(21, 8, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل ali ahmad', 'warning', 0, '2026-03-27 10:32:43', NULL),
(22, 9, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل Julian Gallegos', 'warning', 0, '2026-03-27 10:32:43', NULL),
(23, 5, 'تحديث خطة التغذية للطفل youssef mohammed', 'الطفل الآن بعمر 12 شهراً. تم تحديث نظام التغذية إلى الفئة الجديدة.', 'info', 0, '2026-03-27 16:32:17', NULL),
(24, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-03-31 10:03:25', NULL),
(25, 5, 'تحديث خطة التغذية للطفل youssef mohammed', 'الطفل الآن بعمر 12 شهور. يرجى اتباع نظام التغذية الجديد 6 - 12 شهور.', 'info', 0, '2026-03-31 10:03:25', NULL),
(26, 8, 'تحديث خطة التغذية للطفل laila ahmad', 'الطفل الآن بعمر 15 شهور. يرجى اتباع نظام التغذية الجديد 12 - 24 شهور.', 'info', 0, '2026-03-31 10:03:25', NULL),
(27, 5, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل ayla said', 'warning', 0, '2026-03-31 10:03:25', NULL),
(28, 5, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل youssef mohammed', 'warning', 0, '2026-03-31 10:03:25', NULL),
(29, 8, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل laila ahmad', 'warning', 0, '2026-03-31 10:03:25', NULL),
(30, 8, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل ali ahmad', 'warning', 0, '2026-03-31 10:03:25', NULL),
(31, 9, 'تذكير بموعد الرضاعة اليومي', 'لم يتم تسجيل رضاعة اليوم للطفل Julian Gallegos', 'warning', 0, '2026-03-31 10:03:25', NULL),
(32, 5, 'تحديث خطة التغذية للطفل youssef mohammed', 'الطفل الآن بعمر 12 شهراً. تم تحديث نظام التغذية إلى الفئة الجديدة.', 'info', 0, '2026-03-31 10:05:32', NULL),
(33, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-01 07:34:06', NULL),
(34, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-02 10:58:04', NULL),
(35, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-03 09:36:57', NULL),
(36, 5, 'تحديث خطة التغذية للطفل ola', 'الطفل الآن بعمر 0 شهراً. تم تحديث نظام التغذية إلى الفئة الجديدة.', 'info', 0, '2026-04-03 18:35:26', NULL),
(37, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-03 18:44:00', NULL),
(38, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-03 18:44:00', NULL),
(39, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-07 18:14:59', NULL),
(40, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-07 18:14:59', NULL),
(41, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-07 18:14:59', NULL),
(42, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-11 18:15:00', NULL),
(43, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-11 18:15:00', NULL),
(44, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-11 18:15:00', NULL),
(45, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-12 18:15:00', NULL),
(46, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-12 18:15:00', NULL),
(47, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-12 18:15:00', NULL),
(48, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-14 18:15:00', NULL),
(49, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-14 18:15:00', NULL),
(50, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-14 18:15:00', NULL),
(51, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-18 18:15:00', NULL),
(52, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-18 18:15:00', NULL),
(53, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-18 18:15:00', NULL),
(54, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-19 18:15:00', NULL),
(55, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-19 18:15:00', NULL),
(56, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-19 18:15:00', NULL),
(57, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-20 18:15:00', NULL),
(58, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-20 18:15:00', NULL),
(59, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-20 18:15:00', NULL),
(60, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-21 18:15:00', NULL),
(61, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-21 18:15:00', NULL),
(62, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-21 18:15:00', NULL),
(63, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-27 15:16:22', NULL),
(64, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-27 15:16:22', NULL),
(65, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-27 15:16:22', NULL),
(66, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-28 07:06:46', NULL),
(67, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-28 07:06:46', NULL),
(68, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-28 07:06:46', NULL),
(69, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-29 13:02:47', NULL),
(70, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-29 13:02:47', NULL),
(71, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-29 13:02:47', NULL),
(72, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-30 08:25:49', NULL),
(73, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل ola متأخر عن موعده المحدد', 'error', 0, '2026-04-30 08:25:49', NULL),
(74, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-04-30 08:25:49', NULL),
(75, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل Stuart Mccall متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(76, 5, 'تطعيم متأخر: شلل الأطفال الفموي (OPV) - جرعة 1', 'تطعيم شلل الأطفال الفموي (OPV) - جرعة 1 للطفل Kirk Raymond متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(77, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل Stuart Mccall متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(78, 5, 'تطعيم متأخر: الثلاثي البكتيري (DTP) - جرعة 1', 'تطعيم الثلاثي البكتيري (DTP) - جرعة 1 للطفل Kirk Raymond متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(79, 8, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل laila ahmad متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(80, 5, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل Stuart Mccall متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(81, 5, 'تطعيم متأخر: لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'تطعيم لقاح الحصبة والنكاف والحصبة الألمانية (MMR) للطفل Kirk Raymond متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(82, 5, 'تطعيم متأخر: الروتا (Rota) - جرعة 2', 'تطعيم الروتا (Rota) - جرعة 2 للطفل Stuart Mccall متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(83, 5, 'تطعيم متأخر: الروتا (Rota) - جرعة 2', 'تطعيم الروتا (Rota) - جرعة 2 للطفل Kirk Raymond متأخر عن موعده المحدد', 'error', 0, '2026-05-06 18:15:00', NULL),
(84, 5, 'رسالة جديدة من Dr. Ahmad4 (Pediatrician)', 'لديك رسالة جديدة من الطبيب', 'info', 0, '2026-05-06 18:56:23', NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `nutrition_guidelines`
--

CREATE TABLE `nutrition_guidelines` (
  `id` int(11) NOT NULL,
  `age_min_months` int(11) NOT NULL,
  `age_max_months` int(11) NOT NULL,
  `allowed_foods` text NOT NULL,
  `restricted_foods` text NOT NULL,
  `nutrition_tips` text NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `nutrition_guidelines`
--

INSERT INTO `nutrition_guidelines` (`id`, `age_min_months`, `age_max_months`, `allowed_foods`, `restricted_foods`, `nutrition_tips`, `updated_at`) VALUES
(2, 6, 12, 'حليب الأم، حليب الأطفال، خضروات مهروسة، فواكه مهروسة، حبوب الأرز المطبوخة', 'عسل، ملح، سكر، حليب البقر كامل الدسم', 'ابدأ بإدخال الأطعمة تدريجياً واحداً تلو الآخر', '2023-12-31 21:00:00'),
(3, 12, 24, 'حليب الأطفال أو حليب البقر منخفض الدسم، فواكه، خضروات، حبوب، لحوم، أسماك', 'سكريات، أطعمة معلبة، أطعمة سريعة التحضير', 'شجع على تناول الطعام باليد وتناول الوجبات مع العائلة', '2023-12-31 21:00:00'),
(4, 9, 5, 'Dolor alias veniam', 'Labore quis consequa', 'Id est ab nulla adi', '2026-05-06 18:09:41');

-- --------------------------------------------------------

--
-- بنية الجدول `parent_preferred_times`
--

CREATE TABLE `parent_preferred_times` (
  `id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `day_of_week` enum('Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday','Friday') NOT NULL,
  `preferred_start_time` time NOT NULL,
  `preferred_end_time` time NOT NULL,
  `priority` int(11) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `prescriptions`
--

CREATE TABLE `prescriptions` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `doctor_id` int(11) NOT NULL,
  `prescription_date` date NOT NULL DEFAULT curdate(),
  `expiry_date` date NOT NULL,
  `notes` longtext DEFAULT NULL,
  `status` enum('active','expired','cancelled') DEFAULT 'active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `diagnosis` longtext DEFAULT NULL,
  `symptoms` longtext DEFAULT NULL,
  `clinical_notes` longtext DEFAULT NULL,
  `parent_instructions` longtext DEFAULT NULL,
  `follow_up_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `prescriptions`
--

INSERT INTO `prescriptions` (`id`, `child_id`, `doctor_id`, `prescription_date`, `expiry_date`, `notes`, `status`, `created_at`, `updated_at`, `diagnosis`, `symptoms`, `clinical_notes`, `parent_instructions`, `follow_up_date`) VALUES
(1, 6, 6, '2026-04-01', '2026-04-08', 'ملاحظة الطبيب', 'active', '2026-04-01 07:15:29', '2026-04-30 07:20:02', 'التهاب في الحلق', 'سعال , حمى', 'dffd', 'dff', '2026-04-15'),
(6, 9, 6, '2002-11-25', '2012-08-02', 'Lorem dolor aut sit', 'active', '2026-05-02 19:34:12', '2026-05-02 19:34:12', NULL, NULL, NULL, NULL, NULL),
(7, 9, 6, '2002-06-13', '2028-10-11', 'Ut sint non dolor ni', 'active', '2026-05-02 20:35:04', '2026-05-06 17:34:04', 'بيي', 'بيبي', 'بيبيب', 'بيبي', '0000-00-00'),
(10, 7, 6, '2026-05-06', '2026-05-13', NULL, 'active', '2026-05-06 17:38:45', '2026-05-06 17:38:45', '', '', 'Saepe hic ut soluta', 'Quia et sit laboris', NULL),
(15, 6, 6, '1985-08-30', '1985-09-06', NULL, 'cancelled', '2026-05-06 18:01:04', '2026-05-06 18:01:36', 'Laborum et fuga Tot', 'Enim aut ex aspernat', 'Optio eu dolor labo', 'Vitae non magnam aut', '2019-04-04');

-- --------------------------------------------------------

--
-- بنية الجدول `prescription_medications`
--

CREATE TABLE `prescription_medications` (
  `id` int(11) NOT NULL,
  `prescription_id` int(11) NOT NULL,
  `medication_id` int(11) NOT NULL,
  `dosage` varchar(100) NOT NULL,
  `frequency` varchar(100) NOT NULL,
  `duration_days` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `prescription_medications`
--

INSERT INTO `prescription_medications` (`id`, `prescription_id`, `medication_id`, `dosage`, `frequency`, `duration_days`, `notes`, `created_at`, `updated_at`) VALUES
(1, 1, 5, '1', 'every_8_hours', 5, 'ffdfd', '2026-04-03 21:19:09', '2026-04-03 21:19:09'),
(2, 15, 3, 'Molestiae earum et o', 'twice_daily', 0, 'Incidunt autem sit', '2026-05-06 18:01:04', '2026-05-06 18:01:04');

-- --------------------------------------------------------

--
-- بنية الجدول `prescription_renewal_log`
--

CREATE TABLE `prescription_renewal_log` (
  `id` int(11) NOT NULL,
  `original_prescription_id` int(11) NOT NULL,
  `new_prescription_id` int(11) NOT NULL,
  `old_expiry_date` date DEFAULT NULL,
  `new_expiry_date` date DEFAULT NULL,
  `renewed_by` int(11) NOT NULL,
  `renewal_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- بنية الجدول `prescription_renewal_notifications`
--

CREATE TABLE `prescription_renewal_notifications` (
  `id` int(11) NOT NULL,
  `prescription_id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL,
  `nurse_id` int(11) DEFAULT NULL,
  `notification_type` enum('email','sms','in_app') DEFAULT 'in_app',
  `days_before_expiry` int(11) DEFAULT 7,
  `notification_sent` datetime DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- إرجاع أو استيراد بيانات الجدول `prescription_renewal_notifications`
--

INSERT INTO `prescription_renewal_notifications` (`id`, `prescription_id`, `parent_id`, `nurse_id`, `notification_type`, `days_before_expiry`, `notification_sent`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 1, 5, NULL, 'in_app', 7, '2026-04-03 21:31:20', 0, '2026-04-03 19:31:20', '2026-04-03 19:31:20'),
(3, 6, 8, NULL, 'in_app', 7, NULL, 0, '2026-05-02 19:34:12', '2026-05-02 19:34:12'),
(4, 7, 8, NULL, 'in_app', 7, NULL, 0, '2026-05-02 20:35:04', '2026-05-02 20:35:04');

-- --------------------------------------------------------

--
-- بنية الجدول `professional_notes`
--

CREATE TABLE `professional_notes` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_type` enum('doctor','nurse') NOT NULL,
  `note_content` text NOT NULL,
  `note_type` enum('general','sleep_advice') NOT NULL DEFAULT 'general',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `professional_notes`
--

INSERT INTO `professional_notes` (`id`, `child_id`, `user_id`, `user_type`, `note_content`, `note_type`, `created_at`) VALUES
(1, 6, 7, 'nurse', 'الطفلة آيلا تحتاج لمتابعة يومية لدرجة حرارتها بسبب السعال الخفيف، ومراجعة الطبيب إذا استمر ارتفاع الحرارة.', 'general', '2025-10-23 12:00:00'),
(2, 7, 7, 'nurse', 'لتشجيع الطفل على النوم لفترة أطول ليلاً، يجب تحديد طقوس نوم ثابتة وتجنب التحفيز الشديد قبل النوم بساعة.', 'sleep_advice', '2025-10-20 15:30:00'),
(3, 6, 6, 'doctor', 'تم فحص الطفل، الحالة مستقرة. يرجى التركيز على الرضاعة الطبيعية.', 'general', '2025-10-24 07:00:00'),
(5, 6, 7, 'nurse', 'لتشجيع الطفل على النوم لفترة أطول ليلاً، يجب تحديد طقوس نوم ثابتة وتجنب التحفيز الشديد قبل النوم بساعة.', 'sleep_advice', '2025-10-24 12:11:57'),
(6, 6, 7, 'nurse', 'تم تسجيل/تعديل حالة تطعيم: الروتا (Rota) - جرعة 2. تم الإعطاء في 2024-02-26. . ملاحظة الممرض: qq', 'general', '2025-10-24 12:17:03');

-- --------------------------------------------------------

--
-- بنية الجدول `sleep_records`
--

CREATE TABLE `sleep_records` (
  `id` int(11) NOT NULL,
  `child_id` int(11) NOT NULL,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime NOT NULL,
  `is_night` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `sleep_records`
--

INSERT INTO `sleep_records` (`id`, `child_id`, `start_datetime`, `end_datetime`, `is_night`, `created_at`) VALUES
(1, 6, '2026-03-10 20:30:00', '2026-03-11 06:30:00', 1, '2026-03-11 12:47:33'),
(2, 7, '2026-03-11 13:00:00', '2026-03-11 14:30:00', 0, '2026-03-11 12:47:33'),
(3, 9, '2026-03-11 16:11:00', '2026-03-12 04:12:00', 0, '2026-03-11 13:09:07'),
(4, 6, '2026-03-13 10:27:00', '2026-03-13 10:27:00', 0, '2026-03-13 07:27:25');

-- --------------------------------------------------------

--
-- بنية الجدول `sleep_tips`
--

CREATE TABLE `sleep_tips` (
  `id` int(11) NOT NULL,
  `min_age_months` int(11) NOT NULL DEFAULT 0,
  `max_age_months` int(11) DEFAULT NULL,
  `tip_text` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `sleep_tips`
--

INSERT INTO `sleep_tips` (`id`, `min_age_months`, `max_age_months`, `tip_text`, `created_at`) VALUES
(1, 2, 11, 'النوم الكافي', '2026-03-13 07:27:04');

-- --------------------------------------------------------

--
-- بنية الجدول `statistics`
--

CREATE TABLE `statistics` (
  `id` int(11) NOT NULL,
  `date` date NOT NULL,
  `total_users` int(11) DEFAULT 0,
  `total_children` int(11) DEFAULT 0,
  `total_activities` int(11) DEFAULT 0,
  `total_vaccinations` int(11) DEFAULT 0,
  `new_registrations` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `statistics`
--

INSERT INTO `statistics` (`id`, `date`, `total_users`, `total_children`, `total_activities`, `total_vaccinations`, `new_registrations`, `created_at`) VALUES
(1, '2026-02-25', 3, 4, 6, 6, 0, '2026-02-25 11:34:30');

-- --------------------------------------------------------

--
-- بنية الجدول `system_settings`
--

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `system_settings`
--

INSERT INTO `system_settings` (`id`, `setting_key`, `setting_value`, `description`, `updated_at`) VALUES
(1, 'site_name', 'نظام تتبع صحة الطفل', 'اسم الموقع', '2026-02-25 11:31:53'),
(2, 'site_maintenance_mode', '0', 'وضع الصيانة: 0 = مفعل، 1 = معطل', '2026-02-25 11:31:53'),
(3, 'max_users', '1000', 'الحد الأقصى للمستخدمين', '2026-02-25 11:31:53'),
(4, 'enable_ai_features', '1', 'تفعيل ميزات الذكاء الاصطناعي', '2026-02-25 11:31:53'),
(5, 'backup_frequency', 'daily', 'تكرار النسخ الاحتياطية', '2026-02-25 11:31:53');

-- --------------------------------------------------------

--
-- بنية الجدول `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `security_question` varchar(255) NOT NULL,
  `security_answer` varchar(255) NOT NULL,
  `user_type` enum('parent','doctor','nurse','admin') DEFAULT 'parent',
  `specialty` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `clinic_address` varchar(255) DEFAULT NULL,
  `experience_years` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,6) DEFAULT NULL,
  `longitude` decimal(10,6) DEFAULT NULL,
  `location` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `phone`, `password`, `security_question`, `security_answer`, `user_type`, `specialty`, `is_active`, `last_login`, `created_at`, `clinic_address`, `experience_years`, `address`, `latitude`, `longitude`, `location`) VALUES
(1, 'Admin', 'admin@babyhealthtracker.com', '0000000000', '$2y$10$VX2suVY0lJlEy5MMn/9vxOICdO1SUv6Vi1fJ.CVIPBvAWLi2bDF7i', 'Admin', 'admin', 'admin', 'إدارة النظام', 1, '2026-02-25 11:37:52', '2026-02-25 11:31:53', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 'rama alhoshan (Parent)', 'olafatnah68@gmail.com', '09663258741', '$2y$10$cFNuXFuqjfbduG86CdYPJOATStvrLplfKGwVaGCnWhvx21zNEVl3u', 'اسم أول مدرسة التحقت بها؟', 'awaael', 'parent', NULL, 1, NULL, '2025-06-03 14:49:56', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 'Dr. Ahmad4 (Pediatrician)', 'dr.ahmad@clinic.com', '0944658535', '$2y$10$QdcH6cTDk4Qd/BwCwlrrJeecRtK4y3JpYfbOgzSpENuYU2SRBg19m', 'ما هو اسم صديق طفولتك المفضل؟', 'ali', 'doctor', 'طب الأطفال', 1, NULL, '2025-10-23 06:00:00', '', 7, 'طرطوس - المشروع السادس', 24.712929, 46.645417, 'دمشق .سوريا'),
(7, 'Nurse Huda', 'huda@clinic.com', '0988854455', '$2y$10$cFNuXFuqjfbduG86CdYPJOATStvrLplfKGwVaGCnWhvx21zNEVl3u', 'ما هو اسم والدتك قبل الزواج؟', 'fatima', 'nurse', 'تمريض الأطفال', 1, NULL, '2025-10-23 06:01:00', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 'Abeer Salah (Parent)', 'abeer@gmail.com', '0501234567', '$2y$10$cFNuXFuqjfbduG86CdYPJOATStvrLplfKGwVaGCnWhvx21zNEVl3u', 'ما هو اسم صديق طفولتك المفضل؟', 'sara', 'parent', NULL, 1, NULL, '2025-09-01 10:00:00', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 'ola fatnah', 'ola12@example.com', '0994042749', '$2y$10$VX2suVY0lJlEy5MMn/9vxOICdO1SUv6Vi1fJ.CVIPBvAWLi2bDF7i', 'ما هو اسم صديق طفولتك المفضل؟', 'ريم', 'parent', NULL, 1, NULL, '2026-02-12 10:13:57', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 'Ebony Berg', 'lelaguqug@mailinator.com', '044444444', '$2y$10$sH4p0AEFwRDRkYa2iovRkutxsAR32IjHRb2trysZpriq1QPwVxasy', 'اب', 'اب', 'parent', NULL, 1, NULL, '2026-02-25 12:25:50', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- بنية الجدول `vaccines`
--

CREATE TABLE `vaccines` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `target_age` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `vaccines`
--

INSERT INTO `vaccines` (`id`, `name`, `target_age`, `description`, `created_at`) VALUES
(1, 'شلل الأطفال الفموي (OPV) - جرعة 1', 'شهرين', 'الجرعة الأولى للقاح شلل الأطفال', '2025-10-23 06:05:00'),
(2, 'الثلاثي البكتيري (DTP) - جرعة 1', 'شهرين', 'الجرعة الأولى للقاح الخناق والكزاز والسعال الديكي', '2025-10-23 06:05:00'),
(3, 'لقاح الحصبة والنكاف والحصبة الألمانية (MMR)', 'سنة واحدة', 'الجرعة الأولى', '2025-10-23 06:05:00'),
(4, 'الروتا (Rota) - جرعة 2', '4 أشهر', 'الجرعة الثانية للقاح الروتا', '2025-10-24 06:00:00');

-- --------------------------------------------------------

--
-- بنية الجدول `vaccine_schedule`
--

CREATE TABLE `vaccine_schedule` (
  `id` int(11) NOT NULL,
  `vaccine_name` varchar(255) NOT NULL,
  `age_months` int(11) NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- إرجاع أو استيراد بيانات الجدول `vaccine_schedule`
--

INSERT INTO `vaccine_schedule` (`id`, `vaccine_name`, `age_months`, `description`) VALUES
(1, 'BCG', 0, 'لقاح السل'),
(2, 'Hepatitis B', 0, 'لقاح التهاب الكبد B'),
(3, 'DTP', 2, 'لقاح الخناق والسعال الديكي والكزاز'),
(4, 'Polio', 2, 'لقاح شلل الأطفال'),
(5, 'Hib', 2, 'لقاح الإنفلونزا النزفية'),
(6, 'PCV', 2, 'لقاح المكورات السحائية'),
(7, 'Rotavirus', 2, 'لقاح الروتا فيروس'),
(8, 'MMR', 12, 'لقاح الحصبة والنكاف والحصبة الألمانية'),
(9, 'DTP Booster', 18, 'تعزيز لقاح الخناق والسعال الديكي والكزاز'),
(10, 'Hepatitis A', 12, 'لقاح التهاب الكبد A'),
(11, 'Varicella', 12, 'لقاح الجدري المائي'),
(12, 'HPV', 120, 'لقاح فيروس الورم الحليمي البشري'),
(13, 'BCG', 0, 'لقاح السل'),
(14, 'Hepatitis B', 0, 'لقاح التهاب الكبد B'),
(15, 'DTP', 2, 'لقاح الخناق والسعال الديكي والكزاز'),
(16, 'Polio', 2, 'لقاح شلل الأطفال'),
(17, 'Hib', 2, 'لقاح الإنفلونزا النزفية'),
(18, 'PCV', 2, 'لقاح المكورات السحائية'),
(19, 'Rotavirus', 2, 'لقاح الروتا فيروس'),
(20, 'MMR', 12, 'لقاح الحصبة والنكاف والحصبة الألمانية'),
(21, 'DTP Booster', 18, 'تعزيز لقاح الخناق والسعال الديكي والكزاز'),
(22, 'Hepatitis A', 12, 'لقاح التهاب الكبد A'),
(23, 'Varicella', 12, 'لقاح الجدري المائي'),
(24, 'HPV', 120, 'لقاح فيروس الورم الحليمي البشري');

-- --------------------------------------------------------

--
-- Structure for view `dashboard_stats`
--
DROP TABLE IF EXISTS `dashboard_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `dashboard_stats`  AS SELECT 'إجمالي الآباء' AS `stat_name`, (select count(0) from `users` where `users`.`user_type` = 'parent' and `users`.`is_active` = 1) AS `stat_value`union all select 'إجمالي الأطفال' AS `إجمالي الأطفال`,(select count(0) from `children`) AS `(SELECT COUNT(*) FROM children)` union all select 'تطعيمات مستحقة' AS `تطعيمات مستحقة`,(select count(0) from `child_vaccines` where `child_vaccines`.`status` = 'due') AS `(SELECT COUNT(*) FROM child_vaccines WHERE status = 'due')` union all select 'تطعيمات مقدمة' AS `تطعيمات مقدمة`,(select count(0) from `child_vaccines` where `child_vaccines`.`status` = 'administered') AS `Name_exp_2` union all select 'أطباء نشيطون' AS `أطباء نشيطون`,(select count(0) from `users` where `users`.`user_type` = 'doctor' and `users`.`is_active` = 1) AS `Name_exp_2` union all select 'ممرضات نشيطة' AS `ممرضات نشيطة`,(select count(0) from `users` where `users`.`user_type` = 'nurse' and `users`.`is_active` = 1) AS `Name_exp_2`  ;

-- --------------------------------------------------------

--
-- Structure for view `expired_prescriptions_view`
--
DROP TABLE IF EXISTS `expired_prescriptions_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `expired_prescriptions_view`  AS SELECT `p`.`id` AS `id`, `p`.`child_id` AS `child_id`, `c`.`name` AS `child_name`, `p`.`doctor_id` AS `doctor_id`, `u`.`full_name` AS `doctor_name`, `p`.`prescription_date` AS `prescription_date`, `p`.`expiry_date` AS `expiry_date`, to_days(curdate()) - to_days(`p`.`expiry_date`) AS `days_expired`, `p`.`status` AS `status`, count(`pm`.`id`) AS `medication_count` FROM (((`prescriptions` `p` join `children` `c` on(`p`.`child_id` = `c`.`id`)) join `users` `u` on(`p`.`doctor_id` = `u`.`id`)) left join `prescription_medications` `pm` on(`p`.`id` = `pm`.`prescription_id`)) WHERE `p`.`status` = 'active' AND `p`.`expiry_date` < curdate() GROUP BY `p`.`id`, `p`.`child_id`, `c`.`name`, `p`.`doctor_id`, `u`.`full_name`, `p`.`prescription_date`, `p`.`expiry_date`, `p`.`status` ORDER BY `p`.`expiry_date` DESC ;

-- --------------------------------------------------------

--
-- Structure for view `expiring_prescriptions_view`
--
DROP TABLE IF EXISTS `expiring_prescriptions_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `expiring_prescriptions_view`  AS SELECT `p`.`id` AS `id`, `p`.`child_id` AS `child_id`, `c`.`name` AS `child_name`, `p`.`doctor_id` AS `doctor_id`, `u`.`full_name` AS `doctor_name`, `p`.`prescription_date` AS `prescription_date`, `p`.`expiry_date` AS `expiry_date`, to_days(`p`.`expiry_date`) - to_days(curdate()) AS `days_until_expiry`, `p`.`status` AS `status`, count(`pm`.`id`) AS `medication_count` FROM (((`prescriptions` `p` join `children` `c` on(`p`.`child_id` = `c`.`id`)) join `users` `u` on(`p`.`doctor_id` = `u`.`id`)) left join `prescription_medications` `pm` on(`p`.`id` = `pm`.`prescription_id`)) WHERE `p`.`status` = 'active' AND `p`.`expiry_date` between curdate() and curdate() + interval 14 day GROUP BY `p`.`id`, `p`.`child_id`, `c`.`name`, `p`.`doctor_id`, `u`.`full_name`, `p`.`prescription_date`, `p`.`expiry_date`, `p`.`status` ORDER BY `p`.`expiry_date` ASC ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_logs`
--
ALTER TABLE `admin_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `admin_id` (`admin_id`),
  ADD KEY `idx_admin_id_admin_logs` (`admin_id`),
  ADD KEY `idx_created_at_admin_logs` (`created_at`);

--
-- Indexes for table `age_group_medication_lists`
--
ALTER TABLE `age_group_medication_lists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ai_test_cases`
--
ALTER TABLE `ai_test_cases`
  ADD PRIMARY KEY (`id`),
  ADD KEY `model_type` (`model_type`);

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_appointment` (`child_id`,`doctor_id`,`appointment_date`),
  ADD KEY `parent_id` (`parent_id`),
  ADD KEY `idx_child_id` (`child_id`),
  ADD KEY `idx_doctor_id` (`doctor_id`),
  ADD KEY `idx_appointment_date` (`appointment_date`),
  ADD KEY `idx_appointment_status` (`appointment_status`),
  ADD KEY `idx_confirmation_status` (`confirmation_status`);

--
-- Indexes for table `appointment_analytics`
--
ALTER TABLE `appointment_analytics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_doctor_date` (`doctor_id`,`appointment_date`);

--
-- Indexes for table `appointment_attachments`
--
ALTER TABLE `appointment_attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `uploaded_by` (`uploaded_by`),
  ADD KEY `idx_attachments_appointment` (`appointment_id`);

--
-- Indexes for table `appointment_conflicts`
--
ALTER TABLE `appointment_conflicts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `conflicting_appointment_id` (`conflicting_appointment_id`),
  ADD KEY `idx_appointment_id` (`appointment_id`),
  ADD KEY `idx_resolved` (`resolved`);

--
-- Indexes for table `appointment_notifications`
--
ALTER TABLE `appointment_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notifications_appointment` (`appointment_id`),
  ADD KEY `idx_notifications_user` (`user_id`,`read_at`);

--
-- Indexes for table `appointment_ratings`
--
ALTER TABLE `appointment_ratings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `appointment_id` (`appointment_id`),
  ADD KEY `parent_id` (`parent_id`);

--
-- Indexes for table `appointment_reminders`
--
ALTER TABLE `appointment_reminders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nurse_id` (`nurse_id`),
  ADD KEY `idx_appointment_id` (`appointment_id`),
  ADD KEY `idx_parent_id` (`parent_id`),
  ADD KEY `idx_reminder_sent_status` (`reminder_sent_status`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_reminder_sent` (`reminder_sent`);

--
-- Indexes for table `appointment_requests`
--
ALTER TABLE `appointment_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `parent_id` (`parent_id`),
  ADD KEY `idx_child_id` (`child_id`),
  ADD KEY `idx_doctor_id` (`doctor_id`),
  ADD KEY `idx_request_status` (`request_status`),
  ADD KEY `idx_urgency_level` (`urgency_level`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `appointment_reschedule_log`
--
ALTER TABLE `appointment_reschedule_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `new_appointment_id` (`new_appointment_id`),
  ADD KEY `rescheduled_by` (`rescheduled_by`),
  ADD KEY `idx_original_appointment_id` (`original_appointment_id`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `children`
--
ALTER TABLE `children`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_user_id_children` (`user_id`);

--
-- Indexes for table `child_medication_reminders`
--
ALTER TABLE `child_medication_reminders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `child_id` (`child_id`);

--
-- Indexes for table `child_vaccines`
--
ALTER TABLE `child_vaccines`
  ADD PRIMARY KEY (`id`),
  ADD KEY `child_id` (`child_id`),
  ADD KEY `vaccine_id` (`vaccine_id`),
  ADD KEY `nurse_id` (`nurse_id`),
  ADD KEY `idx_child_id_child_vaccines` (`child_id`),
  ADD KEY `idx_status_child_vaccines` (`status`),
  ADD KEY `idx_due_date_child_vaccines` (`due_date`),
  ADD KEY `vaccine_schedule_id` (`vaccine_schedule_id`);

--
-- Indexes for table `common_symptoms`
--
ALTER TABLE `common_symptoms`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cron_logs`
--
ALTER TABLE `cron_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cron_name` (`cron_name`),
  ADD KEY `idx_executed_at` (`executed_at`);

--
-- Indexes for table `daily_activities`
--
ALTER TABLE `daily_activities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `child_id` (`child_id`),
  ADD KEY `idx_child_id_daily_activities` (`child_id`),
  ADD KEY `idx_date_daily_activities` (`date`);

--
-- Indexes for table `doctor_schedules`
--
ALTER TABLE `doctor_schedules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_schedule` (`doctor_id`,`day_of_week`),
  ADD KEY `idx_doctor_id` (`doctor_id`),
  ADD KEY `idx_day_of_week` (`day_of_week`);

--
-- Indexes for table `doctor_settings`
--
ALTER TABLE `doctor_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `doctor_unavailable_slots`
--
ALTER TABLE `doctor_unavailable_slots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_doctor_id` (`doctor_id`),
  ADD KEY `idx_start_date` (`start_date`),
  ADD KEY `idx_end_date` (`end_date`);

--
-- Indexes for table `educational_videos`
--
ALTER TABLE `educational_videos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `error_logs`
--
ALTER TABLE `error_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `error_type` (`error_type`),
  ADD KEY `created_at` (`created_at`);

--
-- Indexes for table `feeding_schedule`
--
ALTER TABLE `feeding_schedule`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `growth_measurements`
--
ALTER TABLE `growth_measurements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `child_id` (`child_id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `growth_standards`
--
ALTER TABLE `growth_standards`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `age_gender` (`age_months`,`gender`);

--
-- Indexes for table `guest_ai_analysis`
--
ALTER TABLE `guest_ai_analysis`
  ADD PRIMARY KEY (`id`),
  ADD KEY `guest_email` (`guest_email`),
  ADD KEY `analysis_type` (`analysis_type`);

--
-- Indexes for table `healthcare_centers`
--
ALTER TABLE `healthcare_centers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `landing_statistics`
--
ALTER TABLE `landing_statistics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `stat_key` (`stat_key`);

--
-- Indexes for table `medical_articles`
--
ALTER TABLE `medical_articles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `medical_visits`
--
ALTER TABLE `medical_visits`
  ADD PRIMARY KEY (`id`),
  ADD KEY `child_id` (`child_id`),
  ADD KEY `doctor_id` (`doctor_id`);

--
-- Indexes for table `medications`
--
ALTER TABLE `medications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `created_by` (`created_by`);

--
-- Indexes for table `medication_interactions`
--
ALTER TABLE `medication_interactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `medication_a_id` (`medication_a_id`),
  ADD KEY `medication_b_id` (`medication_b_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `recipient_id` (`recipient_id`),
  ADD KEY `child_id` (`child_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `fk_prescription_notifications` (`prescription_id`);

--
-- Indexes for table `nutrition_guidelines`
--
ALTER TABLE `nutrition_guidelines`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `parent_preferred_times`
--
ALTER TABLE `parent_preferred_times`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_parent_id` (`parent_id`);

--
-- Indexes for table `prescriptions`
--
ALTER TABLE `prescriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_child_id` (`child_id`),
  ADD KEY `idx_doctor_id` (`doctor_id`),
  ADD KEY `idx_expiry_date` (`expiry_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `prescription_medications`
--
ALTER TABLE `prescription_medications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_prescription_id` (`prescription_id`),
  ADD KEY `idx_medication_id` (`medication_id`);

--
-- Indexes for table `prescription_renewal_log`
--
ALTER TABLE `prescription_renewal_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `new_prescription_id` (`new_prescription_id`),
  ADD KEY `renewed_by` (`renewed_by`),
  ADD KEY `idx_original_prescription_id` (`original_prescription_id`),
  ADD KEY `idx_renewal_date` (`renewal_date`);

--
-- Indexes for table `prescription_renewal_notifications`
--
ALTER TABLE `prescription_renewal_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `nurse_id` (`nurse_id`),
  ADD KEY `idx_prescription_id` (`prescription_id`),
  ADD KEY `idx_parent_id` (`parent_id`),
  ADD KEY `idx_notification_sent` (`notification_sent`),
  ADD KEY `idx_is_read` (`is_read`);

--
-- Indexes for table `professional_notes`
--
ALTER TABLE `professional_notes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `child_id` (`child_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_child_id_professional_notes` (`child_id`),
  ADD KEY `idx_user_id_professional_notes` (`user_id`);

--
-- Indexes for table `sleep_records`
--
ALTER TABLE `sleep_records`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sleep_tips`
--
ALTER TABLE `sleep_tips`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `statistics`
--
ALTER TABLE `statistics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `date` (`date`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `vaccines`
--
ALTER TABLE `vaccines`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `vaccine_schedule`
--
ALTER TABLE `vaccine_schedule`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_logs`
--
ALTER TABLE `admin_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `age_group_medication_lists`
--
ALTER TABLE `age_group_medication_lists`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `ai_test_cases`
--
ALTER TABLE `ai_test_cases`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `appointment_analytics`
--
ALTER TABLE `appointment_analytics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `appointment_attachments`
--
ALTER TABLE `appointment_attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `appointment_conflicts`
--
ALTER TABLE `appointment_conflicts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `appointment_notifications`
--
ALTER TABLE `appointment_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `appointment_ratings`
--
ALTER TABLE `appointment_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `appointment_reminders`
--
ALTER TABLE `appointment_reminders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `appointment_requests`
--
ALTER TABLE `appointment_requests`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `appointment_reschedule_log`
--
ALTER TABLE `appointment_reschedule_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `children`
--
ALTER TABLE `children`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `child_medication_reminders`
--
ALTER TABLE `child_medication_reminders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `child_vaccines`
--
ALTER TABLE `child_vaccines`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=133;

--
-- AUTO_INCREMENT for table `common_symptoms`
--
ALTER TABLE `common_symptoms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `cron_logs`
--
ALTER TABLE `cron_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `daily_activities`
--
ALTER TABLE `daily_activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `doctor_schedules`
--
ALTER TABLE `doctor_schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `doctor_settings`
--
ALTER TABLE `doctor_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `doctor_unavailable_slots`
--
ALTER TABLE `doctor_unavailable_slots`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `educational_videos`
--
ALTER TABLE `educational_videos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `error_logs`
--
ALTER TABLE `error_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `feeding_schedule`
--
ALTER TABLE `feeding_schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `growth_measurements`
--
ALTER TABLE `growth_measurements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `growth_standards`
--
ALTER TABLE `growth_standards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `guest_ai_analysis`
--
ALTER TABLE `guest_ai_analysis`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `healthcare_centers`
--
ALTER TABLE `healthcare_centers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `landing_statistics`
--
ALTER TABLE `landing_statistics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `medical_articles`
--
ALTER TABLE `medical_articles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `medical_visits`
--
ALTER TABLE `medical_visits`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `medications`
--
ALTER TABLE `medications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `medication_interactions`
--
ALTER TABLE `medication_interactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=85;

--
-- AUTO_INCREMENT for table `nutrition_guidelines`
--
ALTER TABLE `nutrition_guidelines`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `parent_preferred_times`
--
ALTER TABLE `parent_preferred_times`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `prescriptions`
--
ALTER TABLE `prescriptions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `prescription_medications`
--
ALTER TABLE `prescription_medications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `prescription_renewal_log`
--
ALTER TABLE `prescription_renewal_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `prescription_renewal_notifications`
--
ALTER TABLE `prescription_renewal_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `professional_notes`
--
ALTER TABLE `professional_notes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `sleep_records`
--
ALTER TABLE `sleep_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `sleep_tips`
--
ALTER TABLE `sleep_tips`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `statistics`
--
ALTER TABLE `statistics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `system_settings`
--
ALTER TABLE `system_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `vaccines`
--
ALTER TABLE `vaccines`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `vaccine_schedule`
--
ALTER TABLE `vaccine_schedule`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- قيود الجداول المُلقاة.
--

--
-- قيود الجداول `admin_logs`
--
ALTER TABLE `admin_logs`
  ADD CONSTRAINT `admin_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointments_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `appointment_analytics`
--
ALTER TABLE `appointment_analytics`
  ADD CONSTRAINT `appointment_analytics_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `appointment_attachments`
--
ALTER TABLE `appointment_attachments`
  ADD CONSTRAINT `appointment_attachments_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_attachments_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `appointment_conflicts`
--
ALTER TABLE `appointment_conflicts`
  ADD CONSTRAINT `appointment_conflicts_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_conflicts_ibfk_2` FOREIGN KEY (`conflicting_appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `appointment_notifications`
--
ALTER TABLE `appointment_notifications`
  ADD CONSTRAINT `appointment_notifications_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_notifications_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `appointment_ratings`
--
ALTER TABLE `appointment_ratings`
  ADD CONSTRAINT `appointment_ratings_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_ratings_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `appointment_reminders`
--
ALTER TABLE `appointment_reminders`
  ADD CONSTRAINT `appointment_reminders_ibfk_1` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_reminders_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_reminders_ibfk_3` FOREIGN KEY (`nurse_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `appointment_requests`
--
ALTER TABLE `appointment_requests`
  ADD CONSTRAINT `appointment_requests_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_requests_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_requests_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `appointment_reschedule_log`
--
ALTER TABLE `appointment_reschedule_log`
  ADD CONSTRAINT `appointment_reschedule_log_ibfk_1` FOREIGN KEY (`original_appointment_id`) REFERENCES `appointments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `appointment_reschedule_log_ibfk_2` FOREIGN KEY (`new_appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `appointment_reschedule_log_ibfk_3` FOREIGN KEY (`rescheduled_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `children`
--
ALTER TABLE `children`
  ADD CONSTRAINT `children_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `child_medication_reminders`
--
ALTER TABLE `child_medication_reminders`
  ADD CONSTRAINT `child_medication_reminders_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `child_vaccines`
--
ALTER TABLE `child_vaccines`
  ADD CONSTRAINT `child_vaccines_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `child_vaccines_ibfk_3` FOREIGN KEY (`nurse_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `child_vaccines_ibfk_4` FOREIGN KEY (`vaccine_schedule_id`) REFERENCES `vaccine_schedule` (`id`);

--
-- قيود الجداول `daily_activities`
--
ALTER TABLE `daily_activities`
  ADD CONSTRAINT `daily_activities_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `doctor_schedules`
--
ALTER TABLE `doctor_schedules`
  ADD CONSTRAINT `doctor_schedules_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `doctor_unavailable_slots`
--
ALTER TABLE `doctor_unavailable_slots`
  ADD CONSTRAINT `doctor_unavailable_slots_ibfk_1` FOREIGN KEY (`doctor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `growth_measurements`
--
ALTER TABLE `growth_measurements`
  ADD CONSTRAINT `growth_measurements_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `growth_measurements_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `medications`
--
ALTER TABLE `medications`
  ADD CONSTRAINT `medications_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `medication_interactions`
--
ALTER TABLE `medication_interactions`
  ADD CONSTRAINT `medication_interactions_ibfk_1` FOREIGN KEY (`medication_a_id`) REFERENCES `medications` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `medication_interactions_ibfk_2` FOREIGN KEY (`medication_b_id`) REFERENCES `medications` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_prescription_notifications` FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `parent_preferred_times`
--
ALTER TABLE `parent_preferred_times`
  ADD CONSTRAINT `parent_preferred_times_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `prescriptions`
--
ALTER TABLE `prescriptions`
  ADD CONSTRAINT `prescriptions_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prescriptions_ibfk_2` FOREIGN KEY (`doctor_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `prescription_medications`
--
ALTER TABLE `prescription_medications`
  ADD CONSTRAINT `prescription_medications_ibfk_1` FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prescription_medications_ibfk_2` FOREIGN KEY (`medication_id`) REFERENCES `medications` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `prescription_renewal_log`
--
ALTER TABLE `prescription_renewal_log`
  ADD CONSTRAINT `prescription_renewal_log_ibfk_1` FOREIGN KEY (`original_prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prescription_renewal_log_ibfk_2` FOREIGN KEY (`new_prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prescription_renewal_log_ibfk_3` FOREIGN KEY (`renewed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- قيود الجداول `prescription_renewal_notifications`
--
ALTER TABLE `prescription_renewal_notifications`
  ADD CONSTRAINT `prescription_renewal_notifications_ibfk_1` FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prescription_renewal_notifications_ibfk_2` FOREIGN KEY (`parent_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `prescription_renewal_notifications_ibfk_3` FOREIGN KEY (`nurse_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- قيود الجداول `professional_notes`
--
ALTER TABLE `professional_notes`
  ADD CONSTRAINT `professional_notes_ibfk_1` FOREIGN KEY (`child_id`) REFERENCES `children` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `professional_notes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
