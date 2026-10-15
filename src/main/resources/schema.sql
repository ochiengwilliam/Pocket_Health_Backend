CREATE TABLE IF NOT EXISTS "user" (
    user_id UUID PRIMARY KEY,
    log_number VARCHAR(255) UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    pin_hash VARCHAR(255) NOT NULL,
    user_category VARCHAR(255) NOT NULL,
    status VARCHAR(255) NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS profile (
    profile_id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES "user"(user_id),
    surname VARCHAR(255) NOT NULL,
    other_names VARCHAR(255),
    date_of_birth DATE,
    gender VARCHAR(255),
    phone_1 VARCHAR(255),
    residence VARCHAR(255),
    region VARCHAR(255),
    relation VARCHAR(255),
    is_primary BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS health_info (
    health_info_id UUID PRIMARY KEY,
    profile_id UUID NOT NULL UNIQUE REFERENCES profile(profile_id),
    identifier VARCHAR(255),
    blood_group VARCHAR(255),
    allergies TEXT,
    chronic_conditions TEXT,
    mental_conditions TEXT,
    long_term_meds TEXT,
    family_history TEXT,
    drug_use TEXT
);

CREATE TABLE IF NOT EXISTS provider (
    provider_id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES "user"(user_id),
    provider_name VARCHAR(255) NOT NULL,
    category VARCHAR(255),
    specialty VARCHAR(255),
    location VARCHAR(255),
    region VARCHAR(255),
    is_verified BOOLEAN NOT NULL DEFAULT false,
    is_available BOOLEAN NOT NULL DEFAULT true,
    rates NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS emergency_contact (
    contact_id UUID PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profile(profile_id),
    name VARCHAR(255) NOT NULL,
    phone_1 VARCHAR(255) NOT NULL,
    phone_2 VARCHAR(255),
    email VARCHAR(255),
    priority SMALLINT DEFAULT 1,
    emergency_type VARCHAR(255)
);

-- Added after the initial release: an email so the automated SOS message can be sent to a contact.
ALTER TABLE emergency_contact ADD COLUMN IF NOT EXISTS email VARCHAR(255);

CREATE TABLE IF NOT EXISTS insurance (
    insurance_id UUID PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profile(profile_id),
    insurer_name VARCHAR(255) NOT NULL,
    policy_number VARCHAR(255),
    phone_1 VARCHAR(255),
    phone_2 VARCHAR(255),
    email VARCHAR(255)
);

-- Added after the initial release: an email so the emergency alert can be sent to the insurer directly.
ALTER TABLE insurance ADD COLUMN IF NOT EXISTS email VARCHAR(255);

CREATE TABLE IF NOT EXISTS wallet (
    wallet_id UUID PRIMARY KEY,
    user_id UUID NOT NULL UNIQUE REFERENCES "user"(user_id),
    balance_kes NUMERIC(14,2) NOT NULL DEFAULT 0,
    updated_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS transaction (
    transaction_id UUID PRIMARY KEY,
    wallet_id UUID NOT NULL REFERENCES wallet(wallet_id),
    amount NUMERIC(14,2) NOT NULL,
    type VARCHAR(255) NOT NULL,
    payment_method VARCHAR(255),
    mpesa_reference VARCHAR(255),
    status VARCHAR(255) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS consultation (
    consultation_id UUID PRIMARY KEY,
    patient_profile_id UUID NOT NULL REFERENCES profile(profile_id),
    provider_id UUID NOT NULL REFERENCES provider(provider_id),
    call_type VARCHAR(255),
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    amount_charged NUMERIC(12,2),
    status VARCHAR(255) NOT NULL DEFAULT 'scheduled'
);

CREATE TABLE IF NOT EXISTS appointment (
    appointment_id UUID PRIMARY KEY,
    patient_profile_id UUID NOT NULL REFERENCES profile(profile_id),
    provider_id UUID NOT NULL REFERENCES provider(provider_id),
    scheduled_at TIMESTAMPTZ NOT NULL,
    duration_slot INTEGER,
    status VARCHAR(255) NOT NULL DEFAULT 'pending',
    attended BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS review (
    review_id UUID PRIMARY KEY,
    reviewer_profile_id UUID NOT NULL REFERENCES profile(profile_id),
    provider_id UUID NOT NULL REFERENCES provider(provider_id),
    rating_quality SMALLINT,
    rating_helpful SMALLINT,
    rating_timely SMALLINT,
    rating_care SMALLINT,
    review_text TEXT
);

CREATE TABLE IF NOT EXISTS document (
    document_id UUID PRIMARY KEY,
    owner_profile_id UUID NOT NULL REFERENCES profile(profile_id),
    doc_type VARCHAR(255),
    file_url TEXT NOT NULL,
    file_name VARCHAR(255),
    shared_with TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS medical_request (
    request_id UUID PRIMARY KEY,
    consultation_id UUID NOT NULL REFERENCES consultation(consultation_id),
    request_type VARCHAR(255),
    content TEXT,
    sent_to_provider_id UUID REFERENCES provider(provider_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS notification (
    notification_id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES "user"(user_id),
    title VARCHAR(255) NOT NULL,
    body TEXT,
    notif_type VARCHAR(255),
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS provider_availability (
    availability_id UUID PRIMARY KEY,
    provider_id UUID NOT NULL REFERENCES provider(provider_id),
    day_of_week SMALLINT NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    slot_duration_minutes INTEGER NOT NULL DEFAULT 30,
    is_active BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS next_of_kin (
    next_of_kin_id UUID PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profile(profile_id),
    full_name VARCHAR(255) NOT NULL,
    relationship VARCHAR(255) NOT NULL,
    phone1 VARCHAR(255) NOT NULL,
    phone2 VARCHAR(255),
    email VARCHAR(255),
    address VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS emergency_alert (
    alert_id UUID PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profile(profile_id),
    alert_type VARCHAR(30) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    notes TEXT,
    location TEXT,
    recording_document_id UUID REFERENCES document(document_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    resolved_at TIMESTAMPTZ
);

-- Health Library: generic educational content shared by all "module" pages (Wellness,
-- Mental Health, First Aid, Child Health & Immunisation, Pregnancy & Lactation, Health
-- Insurance education). module_key distinguishes which module a topic belongs to. Topics
-- start inactive until real content is pasted in and is_active is flipped to true.
CREATE TABLE IF NOT EXISTS health_topic (
    topic_id UUID PRIMARY KEY,
    module_key VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    summary VARCHAR(500),
    body TEXT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT false
);

CREATE INDEX IF NOT EXISTS idx_health_topic_module ON health_topic(module_key);

-- Module seeds: dummy sub-topic content for all 6 modules, for review/demo purposes until
-- real sourced material is pasted in (idempotent — fixed UUIDs, ON CONFLICT DO NOTHING so
-- this is safe to re-run every startup via spring.sql.init.mode=always, and so real content
-- pasted in later never gets overwritten by a restart).
INSERT INTO health_topic (topic_id, module_key, title, summary, body, sort_order, is_active) VALUES
  ('a1b2c3d4-0001-4000-8000-000000000001', 'wellness', 'Nutrition', 'Eating well for everyday health.',
   'Good nutrition starts with eating a variety of whole foods — vegetables, fruits, whole grains, lean proteins, and healthy fats — while limiting ultra-processed foods, added sugar, and excess salt. Aim for balanced plates rather than strict rules, and drink plenty of water throughout the day.

Reading food labels helps you spot hidden sugars and sodium. Small, consistent changes — like swapping sugary drinks for water or adding a vegetable to each meal — tend to stick better than dramatic diet overhauls.', 1, true),
  ('a1b2c3d4-0001-4000-8000-000000000002', 'wellness', 'Physical Activity', 'Staying active at any fitness level.',
   'Adults should aim for at least 150 minutes of moderate activity each week — brisk walking, cycling, or swimming all count. Strength training twice a week helps maintain muscle and bone health as you age.

You don''t need a gym to stay active: taking the stairs, gardening, or a daily walk all add up. Start small and build gradually — consistency matters more than intensity when you''re just getting started.', 2, true),
  ('a1b2c3d4-0001-4000-8000-000000000003', 'wellness', 'Sleep', 'Why rest matters as much as diet and exercise.',
   'Most adults need 7-9 hours of sleep a night for the body and mind to recover properly. Poor sleep is linked to weakened immunity, mood changes, and difficulty concentrating.

Good sleep hygiene includes a consistent bedtime, limiting screens before bed, and keeping your bedroom cool and dark. If you regularly struggle to fall or stay asleep, it''s worth discussing with a healthcare provider.', 3, true),
  ('a1b2c3d4-0001-4000-8000-000000000004', 'wellness', 'Stress Management', 'Coping with everyday pressure.',
   'Everyday stress is normal, but chronic, unmanaged stress can affect both physical and mental health over time. Simple techniques — slow breathing, short breaks, and regular movement — can meaningfully lower stress in the moment.

Building habits like journaling, talking to someone you trust, or setting realistic priorities can reduce stress before it builds up. If stress feels constant or overwhelming, consider reaching out for professional support.', 4, true),
  ('a1b2c3d4-0001-4000-8000-000000000005', 'wellness', 'Preventive Screenings', 'Catching issues early.',
   'Regular checkups can catch health issues early, often before symptoms appear. Common screenings include blood pressure checks, cholesterol tests, and cancer screenings appropriate for your age and risk factors.

Speak with a healthcare provider about which screenings apply to you based on your age, family history, and lifestyle. Staying on top of preventive care is one of the simplest ways to protect long-term health.', 5, true),

  ('a1b2c3d4-0002-4000-8000-000000000001', 'mental_health', 'Understanding Mental Health', 'What mental health means and why it matters.',
   'Mental health refers to emotional, psychological, and social wellbeing — it affects how we think, feel, and handle daily life. Like physical health, it exists on a spectrum and can change over time.

A common misconception is that mental health only matters when something is "wrong." In reality, everyone benefits from paying attention to their mental wellbeing, the same way everyone benefits from looking after their physical health.', 1, true),
  ('a1b2c3d4-0002-4000-8000-000000000002', 'mental_health', 'Stress & Anxiety', 'Recognizing and managing everyday stress and anxiety.',
   'Occasional stress and worry are a normal part of life, but persistent anxiety that interferes with daily activities may be a sign of an anxiety disorder. Common symptoms include restlessness, racing thoughts, and physical tension.

Simple coping tools — deep breathing, grounding exercises, and limiting caffeine — can help in the moment. If anxiety is frequent or hard to manage on your own, a healthcare provider can help identify the right next step.', 2, true),
  ('a1b2c3d4-0002-4000-8000-000000000003', 'mental_health', 'Depression Awareness', 'Spotting the signs of depression in yourself or others.',
   'Depression is more than temporary sadness — it involves persistent low mood, loss of interest in activities, and changes in sleep, appetite, or energy that last for weeks or longer.

Recognizing these signs early, in yourself or someone close to you, matters. Depression is treatable, and reaching out to a healthcare provider or counselor is a strong first step, not a last resort.', 3, true),
  ('a1b2c3d4-0002-4000-8000-000000000004', 'mental_health', 'Coping Strategies', 'Building healthy habits for emotional resilience.',
   'Building emotional resilience is about developing small, sustainable habits: regular physical activity, adequate sleep, staying connected with others, and taking time to reflect through journaling or mindfulness.

No single strategy works for everyone — it''s worth trying a few approaches to see what fits your life. Consistency, even in small doses, tends to matter more than intensity.', 4, true),
  ('a1b2c3d4-0002-4000-8000-000000000005', 'mental_health', 'When to Seek Help', 'Knowing when and how to reach out for professional support.',
   'It''s time to consider professional support when difficult feelings persist for more than two weeks, interfere with work, relationships, or daily tasks, or include thoughts of self-harm.

Starting the conversation can feel hard, but a doctor, counselor, or trusted helpline can guide you toward the right kind of support. Asking for help is a sign of strength, not weakness.', 5, true),
  ('a1b2c3d4-0002-4000-8000-000000000006', 'mental_health', 'Support Resources', 'Where to turn for help.',
   'Support is available through several channels: primary care doctors, licensed counselors and therapists, community mental health services, and crisis helplines for urgent situations.

If you''re unsure where to start, a general practitioner can often point you toward the right specialist or service. No one has to navigate mental health challenges alone.', 6, true),

  ('a1b2c3d4-0003-4000-8000-000000000001', 'first_aid', 'Basic First Aid Kit', 'What to keep on hand for common emergencies.',
   'A well-stocked first aid kit should include adhesive bandages, sterile gauze, adhesive tape, antiseptic wipes, tweezers, scissors, disposable gloves, and any personal medications.

Keep your kit somewhere easy to access at home and in the car, and check it every few months to replace used or expired items.', 1, true),
  ('a1b2c3d4-0003-4000-8000-000000000002', 'first_aid', 'CPR Basics', 'The core steps of cardiopulmonary resuscitation.',
   'CPR (cardiopulmonary resuscitation) combines chest compressions and rescue breaths to keep blood and oxygen flowing when someone''s heart has stopped. For adults, this generally means firm, fast chest compressions in the center of the chest.

This is a general overview only — hands-on certified training is strongly recommended so you can respond confidently and correctly in a real emergency.', 2, true),
  ('a1b2c3d4-0003-4000-8000-000000000003', 'first_aid', 'Treating Cuts & Wounds', 'Cleaning and dressing minor injuries.',
   'For minor cuts, clean the wound with running water, apply gentle pressure with a clean cloth to stop bleeding, then cover with a sterile dressing.

Seek medical care if bleeding doesn''t stop after several minutes, the wound is deep or gaping, or there are signs of infection like increasing redness, swelling, or pus.', 3, true),
  ('a1b2c3d4-0003-4000-8000-000000000004', 'first_aid', 'Burns & Scalds', 'Immediate care for minor burns.',
   'For minor burns, cool the area under cool (not ice-cold) running water for about 10-20 minutes, then cover loosely with a clean, non-stick dressing. Avoid ice, butter, or other home remedies.

Seek urgent medical care for large burns, burns on the face or hands, or any burn that blisters extensively or looks deep.', 4, true),
  ('a1b2c3d4-0003-4000-8000-000000000005', 'first_aid', 'Choking Response', 'Responding to a choking emergency.',
   'A choking person may clutch their throat, struggle to breathe, or be unable to speak or cough. For a conscious adult, back blows followed by abdominal thrusts (the Heimlich maneuver) can help dislodge the obstruction.

Call emergency services immediately if the person can''t breathe, becomes unconscious, or if you''re unsure how to help — this overview doesn''t replace certified first aid training.', 5, true),
  ('a1b2c3d4-0003-4000-8000-000000000006', 'first_aid', 'Fractures & Sprains', 'Handling suspected broken bones and sprains.',
   'A suspected fracture or sprain should be kept still and supported — avoid moving the injured area or trying to realign it. Applying a cold pack wrapped in cloth can help reduce swelling.

Seek medical attention for suspected fractures, especially if there''s visible deformity, inability to bear weight, or severe pain.', 6, true),

  ('a1b2c3d4-0004-4000-8000-000000000001', 'child_immunisation', 'Immunisation Schedule', 'Recommended vaccines by age.',
   'Childhood immunisations protect against serious diseases like measles, polio, and whooping cough, with most vaccines given in a series starting from birth through early childhood.

Following the recommended schedule ensures children build immunity at the right stages of development. Your healthcare provider can confirm which vaccines are due and when.', 1, true),
  ('a1b2c3d4-0004-4000-8000-000000000002', 'child_immunisation', 'Growth & Development Milestones', 'What to expect at each stage.',
   'Children typically reach physical, language, and social milestones within expected age ranges — like sitting up, first words, and early social smiles — though every child develops at their own pace.

Regular check-ups help track growth and development over time. If you notice significant delays compared to typical milestones, it''s worth discussing with a pediatrician.', 2, true),
  ('a1b2c3d4-0004-4000-8000-000000000003', 'child_immunisation', 'Common Childhood Illnesses', 'Recognizing and responding to common illnesses.',
   'Common childhood illnesses include colds, ear infections, and stomach bugs — most resolve with rest, fluids, and time. Fever, congestion, and mild discomfort are common accompanying symptoms.

Seek medical care if a young child has a high or persistent fever, difficulty breathing, unusual lethargy, or if symptoms worsen instead of improving.', 3, true),
  ('a1b2c3d4-0004-4000-8000-000000000004', 'child_immunisation', 'Nutrition for Children', 'Feeding guidance for growing children.',
   'Children need a balance of proteins, whole grains, fruits, vegetables, and healthy fats to support steady growth and development, with portion sizes adjusted for their age.

Establishing regular meal and snack times, and involving children in food choices, can help build healthy eating habits that last into adulthood.', 4, true),
  ('a1b2c3d4-0004-4000-8000-000000000005', 'child_immunisation', 'When to See a Doctor', 'Warning signs that need medical attention.',
   'Warning signs that warrant a prompt doctor''s visit include high fever in infants, difficulty breathing, persistent vomiting, unusual drowsiness, or a rash that doesn''t fade under pressure.

When in doubt, it''s always better to check with a healthcare provider — trust your instincts as a caregiver.', 5, true),

  ('a1b2c3d4-0005-4000-8000-000000000001', 'pregnancy_lactation', 'Prenatal Care', 'Staying healthy through pregnancy.',
   'Regular prenatal checkups help monitor the health of both mother and baby throughout pregnancy, including blood pressure checks, growth scans, and routine screenings.

Starting prenatal care early — ideally as soon as pregnancy is confirmed — gives the best chance to catch and manage any concerns early.', 1, true),
  ('a1b2c3d4-0005-4000-8000-000000000002', 'pregnancy_lactation', 'Nutrition During Pregnancy', 'Eating well for two.',
   'Pregnancy increases the need for key nutrients like folic acid, iron, and calcium, alongside a balanced diet of whole foods and adequate hydration.

Certain foods — like unpasteurized dairy, raw fish, and excess caffeine — are best avoided during pregnancy. A healthcare provider can offer guidance tailored to your needs.', 2, true),
  ('a1b2c3d4-0005-4000-8000-000000000003', 'pregnancy_lactation', 'Labour & Delivery Preparation', 'Getting ready for labour and delivery.',
   'Preparing for labour includes learning about the stages of delivery, discussing pain management options, and creating a birth plan that reflects your preferences.

Attending antenatal classes and talking through questions with your healthcare provider can help you feel more confident and informed as your due date approaches.', 3, true),
  ('a1b2c3d4-0005-4000-8000-000000000004', 'pregnancy_lactation', 'Breastfeeding Basics', 'Getting started with breastfeeding.',
   'Breastfeeding provides ideal nutrition for most infants and offers benefits for both baby and mother, though it can take time and support to establish a good routine.

Common early challenges include latch difficulties and soreness — a lactation consultant or healthcare provider can offer hands-on guidance if breastfeeding feels difficult.', 4, true),
  ('a1b2c3d4-0005-4000-8000-000000000005', 'pregnancy_lactation', 'Postpartum Recovery', 'Caring for yourself after delivery.',
   'The body needs time to heal after childbirth — physically and emotionally. Rest, proper nutrition, and gradual return to activity all support recovery.

Watch for warning signs like heavy bleeding, fever, or persistent low mood, and don''t hesitate to reach out to a healthcare provider — postpartum depression is common and treatable.', 5, true),

  ('a1b2c3d4-0006-4000-8000-000000000001', 'health_insurance_education', 'How Health Insurance Works', 'The basics of health cover.',
   'Health insurance works by pooling contributions (premiums) from many people to help cover the cost of medical care when it''s needed, subject to the plan''s terms and limits.

Key terms to know include premiums (what you pay regularly), cover limits (the maximum payout), and exclusions (what isn''t covered) — understanding these helps you use your cover effectively.', 1, true),
  ('a1b2c3d4-0006-4000-8000-000000000002', 'health_insurance_education', 'NHIF vs Private Cover', 'Comparing public and private health insurance.',
   'Public schemes like NHIF typically offer broad, affordable access to essential care, while private insurance often provides more flexibility, shorter wait times, and access to a wider network of providers — usually at a higher cost.

Many people combine both: a public scheme as a baseline, with private cover for additional services. The right mix depends on your needs and budget.', 2, true),
  ('a1b2c3d4-0006-4000-8000-000000000003', 'health_insurance_education', 'Choosing a Cover Plan', 'What to look for in a health insurance plan.',
   'When comparing health insurance plans, look closely at the annual cover limit, what conditions or treatments are excluded, waiting periods for certain benefits, and the provider network.

It''s worth matching a plan to your actual healthcare needs — for example, maternity or chronic condition cover if relevant to you — rather than choosing based on price alone.', 3, true),
  ('a1b2c3d4-0006-4000-8000-000000000004', 'health_insurance_education', 'Making a Claim', 'How the claims process works.',
   'Most claims start with notifying your insurer as soon as possible, then submitting required documents like medical reports, receipts, and a completed claim form.

Keep copies of everything you submit, and follow up if you don''t hear back within the expected timeframe. Many insurers now offer claims tracking through an app or online portal.', 4, true),
  ('a1b2c3d4-0006-4000-8000-000000000005', 'health_insurance_education', 'Understanding Your Policy', 'Reading the fine print.',
   'Your policy document spells out exactly what is and isn''t covered, including exclusions, waiting periods, and any conditions on specific benefits — it''s worth reading in full, not just the summary.

If anything is unclear, contact your insurer directly for clarification before you need to make a claim, so there are no surprises when it matters most.', 5, true)
ON CONFLICT (topic_id) DO NOTHING;


-- ---------------------------------------------------------------------------------------------
-- Sub-module alignment with the Panel 4 developer's copy (product spec).
-- Idempotent: every UPDATE is guarded on the original demo title, so it runs once and never
-- touches content edited afterwards. New rows use fixed UUIDs + ON CONFLICT DO NOTHING.
-- Interactive sub-modules (symptom checkers, insurance shop/compare, documents, contract) live in
-- the frontend config (src/config/healthModules.ts), not in this table.
-- ---------------------------------------------------------------------------------------------

-- Wellness (spec 15.0): "Stress Management" is renamed "Mental Wellness".
UPDATE health_topic SET title = 'Mental Wellness', summary = 'Looking after your mind, day to day.'
 WHERE topic_id = 'a1b2c3d4-0001-4000-8000-000000000004' AND title = 'Stress Management';

-- Mental Health (spec 16.0): Mental Health & Conditions (16.1 + its condition groups),
-- Consult Mental Health Specialist (16.2), Mental Health Resources (16.3).
-- The earlier demo topics are retired in favour of the spec's structure.
UPDATE health_topic SET is_active = false
 WHERE (topic_id = 'a1b2c3d4-0002-4000-8000-000000000001' AND title = 'Understanding Mental Health')
    OR (topic_id = 'a1b2c3d4-0002-4000-8000-000000000002' AND title = 'Stress & Anxiety')
    OR (topic_id = 'a1b2c3d4-0002-4000-8000-000000000003' AND title = 'Depression Awareness')
    OR (topic_id = 'a1b2c3d4-0002-4000-8000-000000000004' AND title = 'Coping Strategies')
    OR (topic_id = 'a1b2c3d4-0002-4000-8000-000000000005' AND title = 'When to Seek Help')
    OR (topic_id = 'a1b2c3d4-0002-4000-8000-000000000006' AND title = 'Support Resources');

INSERT INTO health_topic (topic_id, module_key, title, summary, body, sort_order, is_active) VALUES
  ('a1b2c3d4-0002-4000-8000-000000000101', 'mental_health', 'Mental Health & Conditions', 'What mental health is, and the ways we can be mentally unwell.',
   'In an ever-changing world, we are becoming more in tune with our mental health, recognising the value our thoughts and feelings play in shaping our lives and interactions. The mind runs every aspect of the body, so if our mental health is jeopardised, every other aspect of health is too. Our mental health is a product of nature and nurture, with society playing a huge role.

We are all in a state of active thoughts, feelings and behaviour, and the mind usually rationalises everyday conflict through small goals and rewards. Sometimes it cannot find that harmony, and this shows up as anger, sadness, hopelessness, doubt, anxiety or agitation. That is normal in short instances, but when it is prolonged, recurrent or drives hurtful behaviour, it may signal that we are mentally unwell and need a remedy, a balance.

This balance point differs from person to person because our lived experiences are different. In mental health there is no one-size-fits-all: it is okay if a therapy does not work for you, and to keep looking for the one that does. Simply put, sound mental health is finding a balance of kindness to yourself and your society.

Ways we can be mentally unwell (see each topic in this module):
- Conditions relating to mood, like bipolar disorder, mania and depression
- Conditions relating to anxiety, like phobias and social anxiety
- Conditions relating to perception, like schizophrenia
- Conditions relating to habits and character, like narcissism and OCPD (personality disorders)
- Dependency on drugs, like opioid dependency (substance use disorders)
- Conditions relating to eating, like anorexia and bulimia
- Disorders relating to experienced trauma, like PTSD
- Disorders relating to sleep, like insomnia
- Physical symptoms without an explainable physical cause (somatic symptom disorder), like panic disorder and pain disorder
- Others, such as conduct disorder, ADHD, ODD, dementia, dissociation and impulse control conditions', 1, true),

  ('a1b2c3d4-0002-4000-8000-000000000102', 'mental_health', 'Conditions Relating to Mood', 'Depression, bipolar disorder, mania and hypomania.',
   'Variations in mood are normal - we cycle through joy, sorrow, hope, grief and apathy. When high or low moods are prolonged, recurrent or intense, limit daily life, or lead to harm to self or others, they may be of concern.

- Depression: a prolonged low mood.
- Bipolar disorder: significant cycling between high and low moods, at times at the extremes of both.
- Mania and hypomania: prolonged high moods, with hypomania shorter or less intense than mania.
Mood conditions can also be linked to pregnancy and lactation, seasons or events (seasonal affective disorder), or be long-term (chronic depression).

Signs & symptoms vary from person to person and episode to episode. Depression may bring feelings of being down, empty, guilty, worthless, a burden, restless or disconnected, or of life lacking purpose. Mania and hypomania may bring unwaning excitement, agitation, disinhibition and risk taking. Some people cycle rapidly between the two (a mixed state). Both extremes can lead to self-harm or harm to others.

Triggers and drivers include genetics, childhood and life experiences, stress and trauma (neglect, bullying, abuse, grief, harsh work conditions), drugs such as cocaine and alcohol, side effects of some prescription medicines, and medical conditions like thyroid, adrenal or pituitary problems.

Management:
- Psychotherapy, such as cognitive behaviour therapy, interpersonal therapy, psychodynamic therapy and behavioural activation
- Medication, such as antidepressants, lithium, mood stabilisers and antipsychotics, alone or combined with therapy
- Supportive measures: knowing your mood and warning signs, reducing triggers, a healthy sleep schedule, limiting drug use, exercise and stress management
- Support systems: family, friends and peer support
- Preventing relapse, including coping mechanisms

If you or someone else is having a depressive or manic episode that needs emergency care, go to the Emergency module. To find a mental health provider, see Consult Mental Health Specialist.', 2, true),

  ('a1b2c3d4-0002-4000-8000-000000000103', 'mental_health', 'Conditions Relating to Anxiety', 'Generalised anxiety, social anxiety, panic disorder and phobias.',
   'Worry before an exam, interview or date is a healthy way for the mind to prepare. When worry or fear becomes an ever-present part of life, either generally or in certain situations, it may be an anxiety condition.

Types include:
- Generalised anxiety disorder - lingering, notable anxiety without specific triggers
- Social anxiety disorder - triggered by social events
- Panic disorder - recurrent intense episodes of fear with physical symptoms like sweating, fainting, pounding heartbeat and breathlessness
- Specific phobias - fear of particular things or activities
- Separation anxiety - fear of separation from a person or place
- Selective mutism - not speaking in certain situations despite being able to speak
- Drug-induced anxiety, and other unspecified anxiety

Symptoms include lingering worry, trouble falling or staying asleep, poor concentration, restlessness, light-headedness, hot flushes and sweating. In a panic attack there may be a fast pounding heartbeat, fast breathing, confusion, terror, a feeling of impending doom and loss of control.

Triggers and drivers include genetics, childhood experiences, stress and trauma, alcohol, caffeine, certain occupations, and medical conditions such as an overactive thyroid.

Helpful for panic attacks - grounding: count each breath and try to slow it, hold onto and focus on a nearby object, and use a go-to calming thought, phrase, song or place. Have a trusted person at work or school who can help when an episode is overwhelming.

Long-term management:
- Psychotherapy, such as cognitive behaviour therapy, acceptance and commitment therapy, and applied relaxation
- Medication (anxiolytics), depending on response
- Supportive measures: reducing triggers and caffeine, routines like a sleep schedule, limiting drug use, exercise and calming techniques
- Support systems and relapse prevention

If you or someone else is having a panic attack that needs emergency care, go to the Emergency module.', 3, true),

  ('a1b2c3d4-0002-4000-8000-000000000104', 'mental_health', 'Conditions Relating to Perception', 'Schizophrenia, psychosis and schizoaffective disorder.',
   'Our idea of reality is based on what our mind perceives, and a shared reality between people is regarded as normal. Some people perceive things others do not - seeing, hearing or feeling things, or having dominant, inserted or otherworldly thoughts. If these do not remit, cause distress, make coping difficult or risk harm to self or others, help can bring a better quality of life.

Conditions include:
- Schizophrenia - psychosis symptoms including chaotic thought and speech, delusions, hallucinations and focus on the odd
- Schizoaffective disorder - a mix of psychosis and mood symptoms, with episodes of mania or depression
These exist on a spectrum, from mild intermittent symptoms to persistent ones.

Signs & symptoms may include confused or chaotic thoughts, speech or actions, overwhelming fear or suspicion, impulsive actions, hearing voices or seeing things (hallucinations), feeling invincible or persecuted or that thoughts are broadcast (delusions), odd deeply rooted beliefs, and extremes of mood.

Causes and triggers include a genetic predisposition, often with a family link, past and present stress and trauma, drugs such as marijuana, cocaine and alcohol, and conditions such as head injury, brain tumours or stroke.

Management:
- Psychotherapy, such as cognitive behaviour therapy (including mindfulness-based CBT), interpersonal and psychodynamic therapy
- Medication, such as antipsychotics
- Rerouting therapies - channelling energy into enjoyed skills like music, art or engineering
- Supportive measures, support systems and relapse prevention

If you or someone else is having a psychotic episode that needs emergency care, go to the Emergency module.', 4, true),

  ('a1b2c3d4-0002-4000-8000-000000000105', 'mental_health', 'Conditions Relating to Habits & Character (Personality Disorders)', 'Patterns of behaviour that affect healthy relationships.',
   'We all have quirks. When behaviour and habits are largely marked by hurtful, rigid and sustained traits that affect our relationships and quality of life, it may be a personality disorder. These conditions often overlap and vary in extent, so management is tailored to the individual.

Cluster A - odd or eccentric:
- Paranoid: deep distrust of others and a feeling of persecution
- Schizoid: marked lack of emotion and withdrawal from social life
- Schizotypal: intense preoccupation with the peculiar and discomfort in social settings

Cluster B - emotional or erratic:
- Narcissistic: a distorted sense of self-importance and entitlement, with little empathy
- Histrionic: a need for constant attention and emotional extremes
- Borderline: rapidly shifting emotions, unstable relationships and impulsive actions
- Antisocial: deep disregard for the feelings and rights of others

Cluster C - anxious or fearful:
- OCPD: a rigid need for order, perfection and control
- Dependent: a deep need to be cared for, with insecurity and jealousy
- Avoidant: feelings of inadequacy, fear of criticism and avoidance of social contact

Management includes psychotherapy (such as cognitive behaviour therapy and interpersonal therapy), and medication where there is overlap with conditions like depression or anxiety.', 5, true),

  ('a1b2c3d4-0002-4000-8000-000000000106', 'mental_health', 'Dependency on Drugs (Substance Use Disorders)', 'When drug or alcohol use becomes a dependency.',
   'People respond differently to drugs, and some are more genetically predisposed to addiction. Some drugs, like opioids and tobacco, are highly addictive, while others, like marijuana and alcohol, can still create dependency through the comfort or escape they provide and their withdrawal symptoms. Dependency is rarely a choice - people become locked in a cycle that is hard to break.

Signs that drug use may be of concern:
- Cannot do ordinary tasks without the drug
- Cannot go a couple of days without it
- Binging, or losing time or memory from use
- Continued use despite harm to relationships and functioning
- Spending considerable time, effort and money getting and using the drug

It is easy to believe use is under control, so insight and seeking help early matter. It is possible to build meaningful relationships not linked to drug use.

Management includes psychotherapy, medical treatment for instances like alcohol withdrawal and opioid addiction, and support programmes such as methadone substitution therapy.

If you or someone else is experiencing the effects of drug overuse, like alcohol intoxication or opioid overdose, go to the Emergency module.', 6, true),

  ('a1b2c3d4-0002-4000-8000-000000000107', 'mental_health', 'Conditions Relating to Eating', 'Anorexia, bulimia, binge eating and other eating disorders.',
   'Not everyone enjoys food or eating the same way. Lack of enjoyment, worry about food, or overindulgence as a comfort can lead to eating disorders, which can happen to anyone of any age, build or wellness - not everyone has visible symptoms.

Common eating disorders:
- Bulimia - binging then purging, from guilt, lack of control or anxiety
- Anorexia - inadequate food intake from anxiety about food, or a need for perfection or a limited diet
- Binge eating - a compulsive need to eat frequently or heavily
- Rumination - regurgitating eaten food without a physical cause
- Pica - eating non-food items like stones, charcoal or plastic
- Restrictive food intake - avoiding foods because of their texture, smell or other characteristics
- Other specified feeding and eating disorder (OSFED)

Triggers and drivers include social pressure (including social media), stress and trauma, relived past experiences, shaped ideas of perfection, other mental conditions, and physical illnesses such as diabetes.

Management:
- Psychotherapy, such as cognitive behaviour therapy for eating disorders, interpersonal and psychodynamic therapy
- Family-focused therapy, dialectical behaviour therapy and MANTRA
- Medication for underlying mental conditions
- Rerouting therapies, supportive measures, support systems and relapse prevention

If you or someone else has severe symptoms from an eating disorder, go to the Emergency module.', 7, true),

  ('a1b2c3d4-0002-4000-8000-000000000108', 'mental_health', 'Consult Mental Health Specialist', 'Find psychologists, counsellors and psychiatrists.',
   'Contact a mental health provider if you, or someone you care for, is looking for or in need of mental health support.

To find one on PocketHealth, go to Find Providers and choose Psychologists & Counsellors, or search for Psychiatrists under Doctors.

If someone is in immediate danger, use the Emergency module.', 8, true),

  ('a1b2c3d4-0002-4000-8000-000000000109', 'mental_health', 'Mental Health Resources', 'Information, helplines and organisations.',
   'Information on most mental health conditions, articles, quizzes and other resources:
- https://psychcentral.com/
- https://www.mind.org.uk/information-support/types-of-mental-health-problems/

Mental health resources, helplines and organisations:
- https://www.healthline.com/health/mental-health-resources
- https://pmhealthnp.com/children-resources/

Kenya:
- Mental Health Support, Befrienders Kenya: +254722178177, befrienderskenya@gmail.com', 9, true)
ON CONFLICT (topic_id) DO NOTHING;

-- Child Health & Immunisation (spec 13.0): a) Unwell Child - Check Symptoms & Conditions (frontend
-- tool, position 1), b) Immunisation Chart, c) Growth & Milestones, d) Child Nutrition,
-- e) Chronic Conditions, f) Children Resources.
UPDATE health_topic SET title = 'Immunisation Chart', summary = 'Vaccine schedule and reminders for children under 12.', sort_order = 2,
   body = 'The immunisation chart tracks vaccines for every profile under 12 years old registered on your account, based on the child''s date of birth and your country''s immunisation schedule.

- A vaccination schedule is generated for each child, with due dates for every vaccine dose.
- You can record whether each vaccine has been received, and edit immunisation information.
- Reminders are sent 2 weeks before a vaccine, 3 days before, and at 7am on the day.
- If a vaccine isn''t updated a week after its due date, you''ll be prompted to update it (for example, "Measles dose 2 vaccine due a week ago not updated, please update").

Where a country schedule isn''t available, you can enter the vaccines and the age (in weeks or months) for each, and the app will generate the vaccination dates.

Keep your child''s vaccination card up to date, and check with your clinic about catch-up doses if any were missed.'
 WHERE topic_id = 'a1b2c3d4-0004-4000-8000-000000000001' AND title = 'Immunisation Schedule';

UPDATE health_topic SET title = 'Growth & Milestones', summary = 'Normal milestones, growth charts, and delayed milestones.', sort_order = 3,
   body = 'Normal milestones
Children reach social and physical milestones - such as neck support, social smile, sitting, crawling, walking and talking - at broadly predictable ages.

Growth tables & charts
Growth charts compare a child''s weight and height with others of the same age and sex. Weigh and measure regularly (your clinic records these) and discuss any drop or jump across chart lines.

Delayed milestones
A delayed milestone is when a baby or child does not show the expected behaviour or activity for their age. Every child develops at their own pace, with an allowance of weeks to months either side, and some milestones have wider ranges than others (walking, for example, is usually between 10 and 14 months). Many children with a delay reach the milestone in due time without any underlying problem, but it is prudent to consult a qualified professional if you have concerns.

Common delays include delayed neck support, social smile, sitting, crawling, walking and speech.

Commonest acquired causes: vitamin D deficiency, other dietary deficiencies (including breastfeeding difficulties), the nurturing environment, and illness.
Congenital causes include autism, Down syndrome, cerebral palsy, and neurological conditions such as those following lack of oxygen at birth.'
 WHERE topic_id = 'a1b2c3d4-0004-4000-8000-000000000002' AND title = 'Growth & Development Milestones';

UPDATE health_topic SET title = 'Child Nutrition', summary = 'Feeding guidance by age.', sort_order = 4,
   body = '0-6 months
Breast milk (or infant formula where breastfeeding isn''t possible) provides everything a baby needs. Exclusive breastfeeding is recommended for the first 6 months.

6-12 months
Start complementary foods alongside breast milk - soft, mashed foods, moving gradually to a variety of textures and food groups. Offer water in a cup with meals.

12-36 months
Children can eat family foods, cut to a safe size. A helpful guide for 1-4 year olds is "5532-a-day": 5 portions of starchy foods, 5 or more of fruit and vegetables, 3 of dairy and 2 of protein foods (3 if vegetarian), with 6-8 drinks a day, mostly water.

36 months and above
A varied, balanced diet like the rest of the family''s, with limited sugary snacks and drinks.

Speak to your clinic or a nutritionist about vitamin supplements, allergies or concerns about your child''s growth.'
 WHERE topic_id = 'a1b2c3d4-0004-4000-8000-000000000004' AND title = 'Nutrition for Children';

-- The symptom checker (Unwell Child) replaces these two demo topics.
UPDATE health_topic SET is_active = false
 WHERE (topic_id = 'a1b2c3d4-0004-4000-8000-000000000003' AND title = 'Common Childhood Illnesses')
    OR (topic_id = 'a1b2c3d4-0004-4000-8000-000000000005' AND title = 'When to See a Doctor');

INSERT INTO health_topic (topic_id, module_key, title, summary, body, sort_order, is_active) VALUES
  ('a1b2c3d4-0004-4000-8000-000000000006', 'child_immunisation', 'Chronic Conditions', 'Long-term conditions in children, and support.',
   'Many factors, both nature and nurture, can combine to lead to chronic conditions in children. They can arise from genetics - every child inherits some of their parents'' genes and also has genetics unique to them - and from conditions at conception, during pregnancy, at birth and after birth.

Some conditions can be detected during pregnancy and early life: there are markers for Down syndrome and sickle cell disease, and some differences can be seen on ultrasound or other imaging, although these tests are not available to everyone. Dedicated antenatal and postnatal care helps with understanding, detecting and managing these conditions.

Despite everyone''s best efforts, some conditions still arise, and they can be hard to process. Good support systems help families decide on and manage care.

Common chronic conditions in children:
- Sickle cell disease
- Leukaemia and other tumours
- Glycogen storage disease
- Autism
- Cerebral palsy
- Neurological conditions
- Down syndrome', 5, true),

  ('a1b2c3d4-0004-4000-8000-000000000007', 'child_immunisation', 'Children Resources', 'Guides and support for caring for children.',
   'Guides:
- Vaccine information booklet
- First aid manual (see the First Aid module)
- Children helpers training modules
- Comprehensive nutrition guide
- Care of autistic children

Autism support:
- https://www.autismspeaks.org/

Learning and care options for children with chronic conditions are being added.', 6, true)
ON CONFLICT (topic_id) DO NOTHING;

-- Pregnancy & Lactation (spec 14.0): a) Menstrual Cycle (Period Cycle), b) Normal Pregnancy/Lactation,
-- c) Unwell in Pregnancy/Lactation (frontend tool, position 3), d) Nutrition, Physical & Wellness,
-- e) Pregnancy/Lactation Resources.
UPDATE health_topic SET title = 'Normal Pregnancy/Lactation', summary = 'Antenatal care, labour, breastfeeding and recovery.', sort_order = 2,
   body = 'Antenatal care
Regular antenatal check-ups monitor the health of mother and baby, including blood pressure checks, growth scans and routine screenings. Start as soon as pregnancy is confirmed.

Labour & delivery
Learn about the stages of labour, discuss pain relief options, and make a birth plan. Antenatal classes and talking questions through with your provider help you feel prepared.

Breastfeeding
Breast milk gives ideal nutrition for most babies and benefits mother and baby. It can take time and support to establish - latch difficulties and soreness are common early on, and a lactation consultant, nurse or midwife can help.

Recovery after delivery
The body needs time to heal physically and emotionally. Rest, good nutrition and a gradual return to activity support recovery. Watch for heavy bleeding, fever or persistent low mood, and contact a provider if they occur - postpartum depression is common and treatable.'
 WHERE topic_id = 'a1b2c3d4-0005-4000-8000-000000000001' AND title = 'Prenatal Care';

UPDATE health_topic SET title = 'Nutrition, Physical & Wellness', summary = 'Eating, activity and wellbeing in pregnancy and breastfeeding.', sort_order = 4,
   body = 'Nutrition
Pregnancy increases the need for nutrients like folic acid, iron and calcium, alongside a balanced diet of whole foods and plenty of fluids. Avoid unpasteurised dairy, raw fish and excess caffeine. Breastfeeding also increases energy and fluid needs - eat regularly and drink to thirst.

Physical activity
Unless your provider advises otherwise, regular moderate activity such as walking or swimming is good for you in pregnancy and after delivery. Build up gradually after birth, especially after a caesarean section.

Wellness
Sleep and rest when you can, accept help, and look after your mental health - talk to your provider if you feel persistently low or anxious.

Take medicines and supplements only on the advice of a clinician while pregnant or breastfeeding.'
 WHERE topic_id = 'a1b2c3d4-0005-4000-8000-000000000002' AND title = 'Nutrition During Pregnancy';

-- Their content is now part of "Normal Pregnancy/Lactation".
UPDATE health_topic SET is_active = false
 WHERE (topic_id = 'a1b2c3d4-0005-4000-8000-000000000003' AND title = 'Labour & Delivery Preparation')
    OR (topic_id = 'a1b2c3d4-0005-4000-8000-000000000004' AND title = 'Breastfeeding Basics')
    OR (topic_id = 'a1b2c3d4-0005-4000-8000-000000000005' AND title = 'Postpartum Recovery');

INSERT INTO health_topic (topic_id, module_key, title, summary, body, sort_order, is_active) VALUES
  ('a1b2c3d4-0005-4000-8000-000000000006', 'pregnancy_lactation', 'Menstrual Cycle (Period Cycle)', 'How the cycle works, and when to get checked.',
   'The menstrual cycle runs from the first day of one period to the first day of the next. A typical cycle is 21 to 35 days, with bleeding lasting 2 to 7 days. Ovulation - when an egg is released - usually happens about 14 days before the next period, and the few days around it are the most fertile.

Tracking your cycle helps you know when to expect your period, understand your fertile window, and notice changes.

See a provider if:
- Periods stop for 3 months or more (and you aren''t pregnant)
- Bleeding is very heavy, lasts more than 7 days, or happens between periods or after sex
- Period pain stops you from doing everyday activities
- Cycles are consistently shorter than 21 days or longer than 35 days', 1, true),

  ('a1b2c3d4-0005-4000-8000-000000000007', 'pregnancy_lactation', 'Pregnancy/Lactation Resources', 'Where to find more guidance and support.',
   'Nutrition in pregnancy and breastfeeding, printable guides and charts:
- British Nutrition Foundation: https://www.nutrition.org.uk/

Mental health support in pregnancy and after delivery:
- See the Mental Health module for resources and helplines, including Befrienders Kenya (+254722178177).

For personal guidance, book an antenatal or postnatal visit, or consult an obstetrician, midwife or lactation consultant through Find Providers.', 5, true)
ON CONFLICT (topic_id) DO NOTHING;

-- Health Insurance (spec 19.0): Shop and Compare, Documents and Sign Contract are frontend tools
-- listed first. These education topics follow them.
UPDATE health_topic SET sort_order = sort_order + 10
 WHERE module_key = 'health_insurance_education' AND sort_order < 10
   AND topic_id IN ('a1b2c3d4-0006-4000-8000-000000000001', 'a1b2c3d4-0006-4000-8000-000000000002',
                    'a1b2c3d4-0006-4000-8000-000000000003', 'a1b2c3d4-0006-4000-8000-000000000004',
                    'a1b2c3d4-0006-4000-8000-000000000005');

-- Adult Unwell (spec 12.0): "Check Symptoms & Conditions" is the frontend symptom-checker tool
-- (listed first). These are the spec's symptom pages 12.1-12.7 plus "Other" (12.27.0).
INSERT INTO health_topic (topic_id, module_key, title, summary, body, sort_order, is_active) VALUES
  ('a1b2c3d4-0007-4000-8000-000000000001', 'adult_unwell', 'Runny Nose', 'Mucous discharge from the nose.',
   'A runny nose is mucous discharge from the nose, light or heavy, occurring with infections, allergies or trauma.

The most common cause is the common cold, typically a viral infection. Runny nose from an infection usually starts 1-3 days after exposure to someone with a cold, which may not always be obvious.

Runny nose from allergies occurs on exposure to something you are sensitive to - early morning cold, perfume, dust, pollen and so on - and often follows a pattern, such as every other morning or when visiting a certain place like a garden. Strong perfume, cold or dust can cause a short, self-limiting runny nose in most people, but in allergic rhinitis it takes little to trigger it and symptoms are more notable or last longer.

Runny nose after trauma follows an injury to the head or face and may come with other symptoms.

Possible conditions causing runny nose:
- Common cold
- Acute upper respiratory tract infection
- Influenza (flu)
- Allergic rhinitis
- Injury/trauma-related nasal discharge
- Other ear, nose and throat conditions', 1, true),

  ('a1b2c3d4-0007-4000-8000-000000000002', 'adult_unwell', 'Nasal Irritation', 'Itchiness or discomfort inside the nose.',
   'Nasal irritation is itchiness or discomfort on the inside of the nose. It is common and often resolves by itself in a short while.

It can also occur with illness, most commonly the common cold. Allergic rhinitis, sinusitis and swellings or lesions inside the nose may also cause it, among other ear, nose and throat conditions.

Possible conditions causing nasal irritation:
- Common cold
- Allergic rhinitis
- Sinusitis
- Intranasal lesions (swellings inside the nose)
- Other ear, nose and throat conditions', 2, true),

  ('a1b2c3d4-0007-4000-8000-000000000003', 'adult_unwell', 'Nasal Congestion', 'A blocked or full feeling in the nose.',
   'Nasal congestion is a sensation of fullness in the nose, which may be due to infection, swelling, allergy, bleeding or a foreign body in the nose.

The commonest cause is the common cold, often with sneezing, runny nose, cough and headache.

Small, painful swellings inside the nose - often infections from touching the nose lining with contaminated fingers - can also cause congestion. They usually resolve on their own but can be very uncomfortable. Other swellings may be growths in the nose.

In allergic rhinitis, congestion follows exposure to a trigger such as sawdust or a garden, often in a pattern.

Congestion from sinusitis can be hard to tell apart from a cold. Sinusitis is suspected when congestion lasts long or comes with notable headache, pain and discomfort.

Congestion from adenoid swelling usually builds slowly, and may only be noticed as new snoring, a nasal voice or audible breathing without difficulty breathing. (The adenoids are the upward extension of the tonsils at the back of the throat, and can enlarge in some people.)

Possible conditions causing nasal congestion:
- Common cold
- Intranasal lesions
- Allergic rhinitis
- Sinusitis
- Adenoid swelling (hypertrophy)
- Influenza (flu)
- Asthma
- Other ear, nose and throat, or head and nerve system conditions', 3, true),

  ('a1b2c3d4-0007-4000-8000-000000000004', 'adult_unwell', 'Sore Throat', 'An itchy, scratchy or painful throat.',
   'A sore throat is an itch, scratchy feeling or pain in the throat or back of the throat.

It often follows exposure to, or inhaling or swallowing, irritant substances. These cases are usually mild and resolve quickly.

Illness can also cause a sore throat - most commonly an acute upper respiratory tract infection, including the common cold, tonsillitis, pharyngitis, laryngotracheitis and oesophagitis, caused by viruses, bacteria or other organisms.

A sore throat can also come from postnasal drip - mucus dripping down the back of the throat with a cold, cough or other ENT conditions.

Possible conditions causing sore throat:
- Acute upper respiratory tract infection (tonsillitis, pharyngitis...)
- Common cold
- Cough
- Foreign body in the throat or oesophagus
- Other ear, nose and throat conditions
- Other chest, breathing and circulation conditions', 4, true),

  ('a1b2c3d4-0007-4000-8000-000000000005', 'adult_unwell', 'Cough', 'Acute (under 8 weeks) and chronic cough.',
   'Cough is the body''s reaction to disturbances of the ear, nose, throat and chest, and usually has an underlying cause. An acute cough lasts under 8 weeks, a chronic cough longer than 8 weeks.

Acute cough most commonly comes with infections such as the common cold, acute upper respiratory tract infection and pneumonia.

Post-viral cough or postnasal drip after a cold can be irritating and last a couple of weeks, often without other symptoms. It tends to respond poorly to cough syrups, antibiotics and inhalers. See a provider to rule out other causes, then use supportive measures: rest, warm fluids, honey, and a clean, aired environment free of irritants.

A reflex cough happens when something irritates or enters the airway, including choking. A foreign body in the airway needs immediate attention, as it may endanger life.

People with sensitive airways - asthma, allergic rhinitis, sinusitis, bronchitis - may cough on its own or with other symptoms, often worse with a cold.

Chronic cough can be caused by pneumonia, tuberculosis, airway infection or swelling (laryngotracheitis, bronchitis), asthma, sinusitis, allergic rhinitis, a foreign body or heart conditions.

The best management is to treat the underlying cause. Supportive treatment: natural honey 10ml by mouth every 8 hours for 5-7 days.

Cough with fever, fast or difficult breathing, lasting longer than 2 weeks, with blood, with easy exhaustion, or with swelling of the limbs, face or abdomen - or any cough of concern - needs a professional review.

Possible conditions causing cough:
- Common cold
- Postnasal drip or post-infection cough
- Acute upper respiratory tract infection
- Pneumonia
- Asthma
- Choking, or a foreign body in the airway, throat or oesophagus
- Allergic rhinitis
- Sinusitis
- Tuberculosis
- Other ENT, chest, breathing and circulation conditions
- Chronic conditions (tumours, metabolic and autoimmune conditions)

Please note that medications should be based on a prescription following a professional medical assessment. Medications may cause allergies, adverse effects or side effects, may interact with each other or other substances, and may be unsafe at certain doses, in certain conditions like pregnancy or illness, or in certain persons.', 5, true),

  ('a1b2c3d4-0007-4000-8000-000000000006', 'adult_unwell', 'Fever', 'A rise in body temperature.',
   'Fever is a rise in body temperature. Normal body temperature is 35.5-37.5 degrees Celsius (95.9-99.5 Fahrenheit), and the body strictly regulates it within this range.

The commonest cause of fever is infection, usually by viruses, bacteria or protozoa such as the malaria parasite. Fever may be the first, or only, symptom of an infection, so it can help to first manage it with supportive measures - cold sponging, body exposure - or fever medication, while watching for other symptoms or for it to resolve.

Common management: paracetamol (acetaminophen) 1000mg by mouth every 8 hours for 3-5 days, or ibuprofen 400mg by mouth every 8 hours for 3-5 days.
People with asthma, or underlying respiratory or gut conditions, may react to or be worsened by NSAIDs like diclofenac and ibuprofen.

Fevers that are not easily controlled by supportive treatment, disabling fevers, fever with other symptoms, fever beyond 3 days, or any fever of concern may need immediate professional attention.

Possible conditions causing fever:
- Common infections: acute upper respiratory tract infection, influenza, pneumonia, malaria, gastroenteritis (diarrhoea), middle ear infection, wound infection, meningitis, tuberculosis, typhoid, Lyme disease, and the common cold (usually only a low-grade fever)
- Other infections
- Burns
- Injuries (trauma)
- Chronic conditions (tumours, metabolic and autoimmune conditions)
- Head, brain and nerve conditions

Please note that medications should be based on a prescription following a professional medical assessment. Medications may cause allergies, adverse effects or side effects, may interact with each other or other substances, and may be unsafe at certain doses, in certain conditions like pregnancy or illness, or in certain persons.', 6, true),

  ('a1b2c3d4-0007-4000-8000-000000000007', 'adult_unwell', 'Headache', 'Common causes and when to seek care.',
   'Headache is very common. The commonest causes are disturbances in the body or surroundings - too little or altered sleep, diet changes or hunger, too much screen time, mental exhaustion, stress, and psychological conditions like anxiety. These headaches are usually mild to moderate, rarely last beyond a few days, and settle when the cause is managed.

Headache can also occur with infections, allergic rhinitis, sinusitis, eye conditions, migraine and injuries.

Supportive treatment includes rest and reducing the disturbance. Medication may be prescribed alongside, for example:
- Paracetamol (acetaminophen) 1000mg by mouth every 8 hours for 3-5 days, or
- Diclofenac 50mg by mouth every 12 hours for 3-5 days, or
- Ibuprofen 400mg by mouth every 8 hours for 3-5 days.
People with asthma, or underlying respiratory or gut conditions, may react to or be worsened by NSAIDs like diclofenac and ibuprofen.

Headaches that are moderate to severe or disabling, follow a specific pattern without an obvious cause, recur in short spans, last long, or respond poorly to supportive treatment need immediate professional attention.

Possible conditions causing headache:
- Common infections: acute upper respiratory tract infection, common cold, sinusitis, gastroenteritis, urinary tract infection, meningitis
- Other infections
- Allergic rhinitis
- Hypertension (high blood pressure)
- Eye conditions
- Migraine
- Stroke
- Head, brain and nerve conditions
- Chest, breathing and circulation conditions
- Chronic conditions (tumours, metabolic and autoimmune conditions)

Please note that medications should be based on a prescription following a professional medical assessment. Medications may cause allergies, adverse effects or side effects, may interact with each other or other substances, and may be unsafe at certain doses, in certain conditions like pregnancy or illness, or in certain persons.', 7, true),

  ('a1b2c3d4-0007-4000-8000-000000000008', 'adult_unwell', 'Other Symptoms - By Body System', 'Not listed? Find conditions by the affected system.',
   'If your main symptom isn''t listed, think about the main affected system or category:
- Head, eyes and the nerves system
- Ear, nose and throat system
- Stomach, gut and abdominal system
- Chest, heart, breathing and circulation system
- Urinary and reproductive systems
- Muscle, bone and the connective system
- Skin and hair
- Injuries, trauma
- Toxins - poisoning or contamination
- Infections
- Burns and electrocution
- Behavioural and social conditions (anxiety, mood, depression, psychosis, drugs...) - see the Mental Health module
- Tumours, malignancies (cancer, growths...)
- Autoimmune and allergy conditions (rheumatic, SLE, MS, psoriasis...)
- Metabolic and hormone conditions (diabetes, thyroid...)
- Blood conditions (sickle cell disease, thalassaemia, leukaemia...)
- Vascular conditions (stroke, vasculitis, heart attack, embolus...)
- Congenital and genetic conditions (autism, Down syndrome, disability...)
- Degenerative conditions (dementia, Parkinson''s...)

Use Check Symptoms & Conditions to pick your one or two main symptoms and see possible conditions. If the results aren''t relevant, or nothing matches, consult a provider or visit a health facility for further help.', 8, true)
ON CONFLICT (topic_id) DO NOTHING;
