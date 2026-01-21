INSERT INTO public.courses (id, title, description, completion_title, completion_message) 
VALUES 
  ('6cc31931-d4b9-1b97-f91d-40b1c8d83553', 'Test Course', 'Some Description', 'Congratulations', 'Well done for completing all the stuff');

INSERT INTO public.course_materials (id, course_id, storage_key, name, "position") 
VALUES 
  ('547cc1b1-69bb-4cf3-1a46-9c805ba8ac56', '6cc31931-d4b9-1b97-f91d-40b1c8d83553', '5475017e-ecd6-0b6b-d2d6-f163bcaf15b7', 'some doc', 0);

INSERT INTO public.quizsections (id, "position", course_id) 
VALUES
  ('f533d5d2-3273-4674-a4c7-9ab99f4a6e64', 1, '6cc31931-d4b9-1b97-f91d-40b1c8d83553'),
  ('9e21853b-afc7-4d30-b9de-f56261ed7e94', 2, '6cc31931-d4b9-1b97-f91d-40b1c8d83553');

INSERT INTO public.quizquestions (id, question, "position", quiz_section_id, is_multi_answer) 
VALUES 
  ('08caca31-4079-45c5-9e4a-17f75758c93f', 'How many days in a week?', 0, 'f533d5d2-3273-4674-a4c7-9ab99f4a6e64', false),
  ('efb38fd0-34a5-4b41-b003-bce496e7c17e', 'Days in year?', 1, 'f533d5d2-3273-4674-a4c7-9ab99f4a6e64', false),
  ('e4f18c90-8fd3-4226-8ad0-5e8988ae38a0', 'Hours in day?', 0, '9e21853b-afc7-4d30-b9de-f56261ed7e94', false);

INSERT INTO public.quizanswers (id, answer, correct_answer, quiz_question_id, "position") 
VALUES 
  ('294eda41-1e7f-43ac-a85b-2a82a70e3f49', '6', false, '08caca31-4079-45c5-9e4a-17f75758c93f', 0),
  ('397e7256-3a21-40fa-be0c-f2f6c52cad05', '7', true, '08caca31-4079-45c5-9e4a-17f75758c93f', 1),
  ('81705a85-43f5-4d3b-95a3-6216b52c7f13', '3', false, '08caca31-4079-45c5-9e4a-17f75758c93f', 2),
  ('073dfcb7-4dc1-4bee-ab2f-f8a2f467e348', '12', false, '08caca31-4079-45c5-9e4a-17f75758c93f', 3),
  ('7d857695-51c0-40b2-9564-95c2dec86f60', '365', true, 'efb38fd0-34a5-4b41-b003-bce496e7c17e', 0),
  ('067b0816-ef10-4589-9c3f-291c6c8d9650', '2', false, 'efb38fd0-34a5-4b41-b003-bce496e7c17e', 1),
  ('628d0694-d6ad-471f-9ee3-9243773926bc', 'asd', false, 'e4f18c90-8fd3-4226-8ad0-5e8988ae38a0', 0),
  ('e88d9d53-cbe7-414e-8c73-0886589c98d7', '24', true, 'e4f18c90-8fd3-4226-8ad0-5e8988ae38a0', 1),
  ('4e466b39-116d-418c-8200-daf885dc7174', '123', false, 'e4f18c90-8fd3-4226-8ad0-5e8988ae38a0', 2),
  ('6a304411-9af1-486f-955d-1c9d453ba1f1', '10', false, 'e4f18c90-8fd3-4226-8ad0-5e8988ae38a0', 3);

INSERT INTO public.videosections (id, title, "position", storage_key, course_id) 
VALUES 
  ('cfb89f18-ae37-4535-b5b9-695ec4112161', 'another video test', 3, '7f1bb376-e97a-70e9-f8f8-972b154d4ffb', '6cc31931-d4b9-1b97-f91d-40b1c8d83553'),
  ('3485675b-6e83-49f8-a062-8206132c118a', 'intro video', 0, 'ba45db4f-9e40-1370-ef6b-de016fbaf85b', '6cc31931-d4b9-1b97-f91d-40b1c8d83553');
