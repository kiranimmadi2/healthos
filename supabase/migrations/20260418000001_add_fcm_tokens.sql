-- Add FCM push notification tokens to patients and doctors
ALTER TABLE patients ADD COLUMN IF NOT EXISTS fcm_token TEXT;
ALTER TABLE doctors  ADD COLUMN IF NOT EXISTS fcm_token TEXT;
