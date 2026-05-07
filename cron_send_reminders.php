<?php
/**
 * Script to send automated reminders for appointments and overdue vaccines
 * This should be run daily via cron job
 */

require_once 'includes/db_config.php';
require_once 'includes/AppointmentNotificationManager.php';

$db = new DatabaseHelper();
$conn = $db->getConnection();
$notificationManager = new AppointmentNotificationManager($conn);

echo "Starting automated reminder system...\n";

// 1. Send appointment reminders for tomorrow
$tomorrow = date('Y-m-d', strtotime('+1 day'));
$appointment_reminder_sql = "SELECT a.id, a.appointment_date, a.appointment_time, 
                                   c.name as child_name, u.full_name as doctor_name,
                                   p.id as parent_id, p.email as parent_email
                            FROM appointments a
                            JOIN children c ON a.child_id = c.id
                            JOIN users u ON a.doctor_id = u.id
                            JOIN users p ON c.user_id = p.id
                            WHERE DATE(a.appointment_date) = ? 
                            AND a.appointment_status IN ('scheduled', 'confirmed')
                            AND a.reminder_sent = 0";

$stmt = $conn->prepare($appointment_reminder_sql);
$stmt->bind_param('s', $tomorrow);
$stmt->execute();
$appointments_result = $stmt->get_result();

$appointment_reminders_sent = 0;
while ($appointment = $appointments_result->fetch_assoc()) {
    $appointment_id = $appointment['id'];
    
    // Send reminder notification
    $success = $notificationManager->sendReminder($appointment_id, 24);
    
    if ($success) {
        // Mark reminder as sent
        $update_sql = "UPDATE appointments SET reminder_sent = 1, reminder_sent_date = NOW() WHERE id = ?";
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bind_param('i', $appointment_id);
        $update_stmt->execute();
        $update_stmt->close();
        
        $appointment_reminders_sent++;
        echo "Sent appointment reminder for appointment ID: $appointment_id\n";
    }
}
$stmt->close();

// 2. Check for overdue vaccines (more than 7 days overdue)
$overdue_date = date('Y-m-d', strtotime('-7 days'));
$overdue_vaccines_sql = "SELECT cv.id, cv.due_date, c.name as child_name, v.name as vaccine_name,
                                u.id as parent_id, u.email as parent_email, u.full_name as parent_name
                         FROM child_vaccines cv
                         JOIN children c ON cv.child_id = c.id
                         JOIN users u ON c.user_id = u.id
                         JOIN vaccines v ON cv.vaccine_id = v.id
                         WHERE cv.due_date < ? 
                         AND cv.status = 'due'
                         AND cv.overdue_notification_sent = 0";

$stmt = $conn->prepare($overdue_vaccines_sql);
$stmt->bind_param('s', $overdue_date);
$stmt->execute();
$overdue_result = $stmt->get_result();

$vaccine_reminders_sent = 0;
while ($vaccine = $overdue_result->fetch_assoc()) {
    $vaccine_record_id = $vaccine['id'];
    
    // Send email notification
    $to = $vaccine['parent_email'];
    $subject = "تنبيه تطعيم متأخر لطفلك " . $vaccine['child_name'];
    $message = "السيد/ة " . $vaccine['parent_name'] . "\n\n" .
               $vaccine['child_name'] . " متأخر عن أخذ التطعيم " . $vaccine['vaccine_name'] .
               " الذي كان مبرمجاً في " . $vaccine['due_date'] . ".\nيرجى الاتصال بالعيادة لتحديد موعد جديد.\n\nشكراً";
    $headers = "From: no-reply@babyhealth.local\r\n";
    $sent = mail($to, $subject, $message, $headers);
    
    // Save to notifications table
    $notifQuery = "INSERT INTO notifications (user_id, title, message, type, created_at) VALUES (?,?,?,?,'warning', NOW())";
    $notifStmt = $conn->prepare($notifQuery);
    $notifTitle = 'تذكير تطعيم متأخر';
    $notifMsg = "طفلك " . $vaccine['child_name'] . " متأخر عن لقاح " . $vaccine['vaccine_name'] . " (الموعد: " . $vaccine['due_date'] . ")";
    $parentId = $vaccine['parent_id'];
    $notifStmt->bind_param('isss', $parentId, $notifTitle, $notifMsg);
    $notifStmt->execute();
    $notifStmt->close();
    
    if ($sent) {
        // Mark as notification sent
        $update_sql = "UPDATE child_vaccines SET overdue_notification_sent = 1, overdue_notification_date = NOW() WHERE id = ?";
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bind_param('i', $vaccine_record_id);
        $update_stmt->execute();
        $update_stmt->close();
        
        $vaccine_reminders_sent++;
        echo "Sent overdue vaccine notification for vaccine record ID: $vaccine_record_id\n";
    }
}
$stmt->close();

// 3. Send upcoming appointment reminders (2 days before)
$upcoming_date = date('Y-m-d', strtotime('+2 days'));
$upcoming_appointments_sql = "SELECT a.id, a.appointment_date, a.appointment_time,
                                      c.name as child_name, u.full_name as doctor_name,
                                      p.id as parent_id, p.email as parent_email
                               FROM appointments a
                               JOIN children c ON a.child_id = c.id
                               JOIN users u ON a.doctor_id = u.id
                               JOIN users p ON c.user_id = p.id
                               WHERE DATE(a.appointment_date) = ?
                               AND a.appointment_status IN ('scheduled', 'confirmed')
                               AND a.upcoming_reminder_sent = 0";

$stmt = $conn->prepare($upcoming_appointments_sql);
$stmt->bind_param('s', $upcoming_date);
$stmt->execute();
$upcoming_result = $stmt->get_result();

$upcoming_reminders_sent = 0;
while ($appointment = $upcoming_result->fetch_assoc()) {
    $appointment_id = $appointment['id'];
    
    // Send upcoming reminder notification
    $success = $notificationManager->sendReminder($appointment_id, 48);
    
    if ($success) {
        // Mark as sent
        $update_sql = "UPDATE appointments SET upcoming_reminder_sent = 1, upcoming_reminder_date = NOW() WHERE id = ?";
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bind_param('i', $appointment_id);
        $update_stmt->execute();
        $update_stmt->close();
        
        $upcoming_reminders_sent++;
        echo "Sent upcoming appointment reminder for appointment ID: $appointment_id\n";
    }
}
$stmt->close();

echo "Reminder system completed:\n";
echo "- Appointment reminders sent: $appointment_reminders_sent\n";
echo "- Overdue vaccine notifications sent: $vaccine_reminders_sent\n";
echo "- Upcoming appointment reminders sent: $upcoming_reminders_sent\n";
echo "Total notifications sent: " . ($appointment_reminders_sent + $vaccine_reminders_sent + $upcoming_reminders_sent) . "\n";

$conn->close();
?>
