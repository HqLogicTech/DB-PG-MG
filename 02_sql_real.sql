
-- ============================================================
-- FeedbackIQ: SQL Practice Dataset
-- PostgreSQL / Supabase
-- ============================================================

BEGIN;

-- 0. Verify that the Supabase Auth user exists.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM auth.users
        WHERE email = 'YOUR_LOGIN_EMAIL'
    ) THEN
        RAISE EXCEPTION
            'Supabase Auth user not found. Replace YOUR_LOGIN_EMAIL with your actual login email.';
    END IF;
END $$;

-- 1. Create/update the application user.
INSERT INTO public.users (auth_user_id, full_name)
SELECT id, 'SQL Practice Owner'
FROM auth.users
WHERE email = 'YOUR_LOGIN_EMAIL'
ON CONFLICT (auth_user_id)
DO UPDATE SET full_name = EXCLUDED.full_name;

-- Store the real application user ID for subsequent inserts.
DROP TABLE IF EXISTS feedbackiq_seed_user;

CREATE TEMP TABLE feedbackiq_seed_user ON COMMIT DROP AS
SELECT id AS user_id
FROM public.users
WHERE auth_user_id = (
    SELECT id
    FROM auth.users
    WHERE email = 'YOUR_LOGIN_EMAIL'
);

-- 2. Organizations
INSERT INTO public.organizations (id, name, slug)
VALUES
('10000000-0000-4000-8000-000000000001',
 'FeedbackIQ Practice Org', 'feedbackiq-sql-practice')
ON CONFLICT DO NOTHING;

-- 3. Organization members
INSERT INTO public.organization_members
    (id, organization_id, user_id, role)
SELECT
    '11000000-0000-4000-8000-000000000001',
    '10000000-0000-4000-8000-000000000001',
    user_id,
    'owner'
FROM feedbackiq_seed_user
ON CONFLICT DO NOTHING;

-- 4. Projects
INSERT INTO public.projects
    (id, organization_id, name, description, created_by)
SELECT
    v.id, v.organization_id, v.name, v.description, u.user_id
FROM (
    VALUES
    (
        '20000000-0000-4000-8000-000000000001'::uuid,
        '10000000-0000-4000-8000-000000000001'::uuid,
        'FeedbackIQ',
        'Customer feedback intelligence SaaS'
    ),
    (
        '20000000-0000-4000-8000-000000000002'::uuid,
        '10000000-0000-4000-8000-000000000001'::uuid,
        'HQLogic Analytics',
        'Analytics and reporting web application'
    )
) AS v(id, organization_id, name, description)
CROSS JOIN feedbackiq_seed_user u
ON CONFLICT DO NOTHING;

-- 5. Documents
INSERT INTO public.documents
    (id, project_id, uploaded_by, name, original_filename,
     file_type, storage_path, file_size_bytes,
     total_records, processed_records, failed_records, status)
SELECT
    v.id, v.project_id, u.user_id, v.name, v.original_filename,
    v.file_type, v.storage_path, v.file_size_bytes,
    4, 4, 0, 'completed'
FROM (
    VALUES
    (
        '30000000-0000-4000-8000-000000000001'::uuid,
        '20000000-0000-4000-8000-000000000001'::uuid,
        'October App Reviews',
        'october_reviews.csv',
        'csv',
        '10000000-0000-4000-8000-000000000001/20000000-0000-4000-8000-000000000001/30000000-0000-4000-8000-000000000001/october_reviews.csv',
        20480::bigint
    ),
    (
        '30000000-0000-4000-8000-000000000002'::uuid,
        '20000000-0000-4000-8000-000000000002'::uuid,
        'October Product Feedback',
        'product_feedback.xlsx',
        'xlsx',
        '10000000-0000-4000-8000-000000000001/20000000-0000-4000-8000-000000000002/30000000-0000-4000-8000-000000000002/product_feedback.xlsx',
        40960::bigint
    )
) AS v(id, project_id, name, original_filename,
       file_type, storage_path, file_size_bytes)
CROSS JOIN feedbackiq_seed_user u
ON CONFLICT DO NOTHING;

-- 6. Feedback records
INSERT INTO public.feedback_records
    (id, document_id, row_number, external_id, feedback_text,
     customer_id, customer_name, rating, feedback_date, metadata)
VALUES
-- FeedbackIQ project
('40000000-0000-4000-8000-000000000001',
 '30000000-0000-4000-8000-000000000001', 1, 'REV-101',
 'The dashboard is intuitive and easy to use.',
 'C-101', 'Aarav', 5, '2026-10-01 10:00:00+00',
 '{"source":"app_store","plan":"pro"}'),
('40000000-0000-4000-8000-000000000002',
 '30000000-0000-4000-8000-000000000001', 2, 'REV-102',
 'CSV uploads fail when the file contains special characters.',
 'C-102', 'Priya', 2, '2026-10-02 11:00:00+00',
 '{"source":"support","plan":"free"}'),
('40000000-0000-4000-8000-000000000003',
 '30000000-0000-4000-8000-000000000001', 3, 'REV-103',
 'The application is slow when processing large datasets.',
 'C-103', 'Rohan', 1, '2026-10-03 12:00:00+00',
 '{"source":"app_store","plan":"pro"}'),
('40000000-0000-4000-8000-000000000004',
 '30000000-0000-4000-8000-000000000001', 4, 'REV-104',
 'The reports are useful, but I need more export options.',
 'C-104', 'Neha', 3, '2026-10-04 13:00:00+00',
 '{"source":"survey","plan":"pro"}'),

-- HQLogic Analytics project
('40000000-0000-4000-8000-000000000005',
 '30000000-0000-4000-8000-000000000002', 1, 'REV-201',
 'Charts are clear and the reports save me time.',
 'C-201', 'Kabir', 5, '2026-10-05 10:00:00+00',
 '{"source":"survey","plan":"business"}'),
('40000000-0000-4000-8000-000000000006',
 '30000000-0000-4000-8000-000000000002', 2, 'REV-202',
 'Good analytics, but integrations are difficult to configure.',
 'C-202', 'Meera', 3, '2026-10-06 11:00:00+00',
 '{"source":"support","plan":"business"}'),
('40000000-0000-4000-8000-000000000007',
 '30000000-0000-4000-8000-000000000002', 3, 'REV-203',
 'The API documentation is confusing and incomplete.',
 'C-203', 'Dev', 2, '2026-10-07 12:00:00+00',
 '{"source":"app_store","plan":"free"}'),
('40000000-0000-4000-8000-000000000008',
 '30000000-0000-4000-8000-000000000002', 4, 'REV-204',
 'Great visualizations and responsive customer support.',
 'C-204', 'Isha', 4, '2026-10-08 13:00:00+00',
 '{"source":"survey","plan":"business"}')
ON CONFLICT DO NOTHING;

-- 7. Document import jobs
INSERT INTO public.document_import_jobs
    (id, document_id, requested_by, status, total_rows,
     imported_rows, skipped_rows, failed_rows,
     error_details, attempts, started_at, completed_at)
SELECT
    v.id, v.document_id, u.user_id, 'completed',
    4, 4, 0, 0, '[]'::jsonb, 1,
    now() - interval '2 hours', now() - interval '1 hour'
FROM (
    VALUES
    (
        '50000000-0000-4000-8000-000000000001'::uuid,
        '30000000-0000-4000-8000-000000000001'::uuid
    ),
    (
        '50000000-0000-4000-8000-000000000002'::uuid,
        '30000000-0000-4000-8000-000000000002'::uuid
    )
) AS v(id, document_id)
CROSS JOIN feedbackiq_seed_user u
ON CONFLICT DO NOTHING;

-- 8. Analysis runs
INSERT INTO public.analysis_runs
    (id, project_id, document_id, requested_by, run_type,
     model_provider, model_name, prompt_version,
     total_records, processed_records, failed_records,
     status, started_at, completed_at)
SELECT
    v.id, v.project_id, v.document_id, u.user_id, 'document',
    'demo', 'feedback-classifier-v1', 'v1',
    4, 4, 0, 'completed',
    now() - interval '50 minutes', now() - interval '45 minutes'
FROM (
    VALUES
    (
        '60000000-0000-4000-8000-000000000001'::uuid,
        '20000000-0000-4000-8000-000000000001'::uuid,
        '30000000-0000-4000-8000-000000000001'::uuid
    ),
    (
        '60000000-0000-4000-8000-000000000002'::uuid,
        '20000000-0000-4000-8000-000000000002'::uuid,
        '30000000-0000-4000-8000-000000000002'::uuid
    )
) AS v(id, project_id, document_id)
CROSS JOIN feedbackiq_seed_user u
ON CONFLICT DO NOTHING;

-- 9. Feedback analyses
INSERT INTO public.feedback_analyses
    (id, feedback_record_id, analysis_run_id, sentiment,
     sentiment_score, topics, positives, negatives,
     improvements, suggestions, summary, raw_output)
VALUES
('70000000-0000-4000-8000-000000000001',
 '40000000-0000-4000-8000-000000000001',
 '60000000-0000-4000-8000-000000000001',
 'positive', 0.94, '["usability","dashboard"]',
 '["intuitive UI"]', '[]',
 '[]', '["Maintain the simple interface"]',
 'Customer likes the intuitive dashboard.',
 '{"demo":true}'),

('70000000-0000-4000-8000-000000000002',
 '40000000-0000-4000-8000-000000000002',
 '60000000-0000-4000-8000-000000000001',
 'negative', -0.85, '["CSV import","reliability"]',
 '[]', '["CSV import failure"]',
 '["Improve special-character handling"]',
 '["Add CSV validation and better error messages"]',
 'Import failures are blocking the customer.',
 '{"demo":true}'),

('70000000-0000-4000-8000-000000000003',
 '40000000-0000-4000-8000-000000000003',
 '60000000-0000-4000-8000-000000000001',
 'negative', -0.96, '["performance","large datasets"]',
 '[]', '["Slow processing"]',
 '["Optimize large dataset processing"]',
 '["Profile slow queries and add batch processing"]',
 'Performance degrades with large datasets.',
 '{"demo":true}'),

('70000000-0000-4000-8000-000000000004',
 '40000000-0000-4000-8000-000000000004',
 '60000000-0000-4000-8000-000000000001',
 'neutral', 0.05, '["reports","exports"]',
 '["Useful reports"]', '[]',
 '["Add export formats"]',
 '["Support CSV and PDF report exports"]',
 'Reports are useful but export options are limited.',
 '{"demo":true}'),

('70000000-0000-4000-8000-000000000005',
 '40000000-0000-4000-8000-000000000005',
 '60000000-0000-4000-8000-000000000002',
 'positive', 0.92, '["visualizations","reporting"]',
 '["Clear charts","Time saving"]', '[]',
 '[]', '["Continue investing in report usability"]',
 'Customer values clear charts and reporting.',
 '{"demo":true}'),

('70000000-0000-4000-8000-000000000006',
 '40000000-0000-4000-8000-000000000006',
 '60000000-0000-4000-8000-000000000002',
 'mixed', 0.10, '["analytics","integrations"]',
 '["Good analytics"]', '["Difficult configuration"]',
 '["Simplify integration setup"]',
 '["Provide guided integration setup"]',
 'Analytics are appreciated but setup is difficult.',
 '{"demo":true}'),

('70000000-0000-4000-8000-000000000007',
 '40000000-0000-4000-8000-000000000007',
 '60000000-0000-4000-8000-000000000002',
 'negative', -0.82, '["API","documentation"]',
 '[]', '["Confusing documentation"]',
 '["Improve API examples and reference docs"]',
 '["Add copy-paste examples and quick-start guide"]',
 'API documentation is a source of friction.',
 '{"demo":true}'),

('70000000-0000-4000-8000-000000000008',
 '40000000-0000-4000-8000-000000000002',
 '60000000-0000-4000-8000-000000000001',
 'negative', -0.60, '["CSV import","validation"]',
 '[]', '["Import errors"]',
 '["Improve import feedback"]',
 '["Show row-level validation errors"]',
 'Repeat analysis example for a second analysis record.',
 '{"demo":true}')
ON CONFLICT DO NOTHING;

-- 10. Project analysis summaries
INSERT INTO public.project_analysis_summaries
    (id, project_id, analysis_run_id, total_feedback,
     positive_count, negative_count, neutral_count, mixed_count,
     average_rating, sentiment_distribution, top_topics,
     common_positives, common_negatives,
     improvement_suggestions, executive_summary)
VALUES
(
 '80000000-0000-4000-8000-000000000001',
 '20000000-0000-4000-8000-000000000001',
 '60000000-0000-4000-8000-000000000001',
 4, 1, 2, 1, 0, 2.75,
 '{"positive":1,"negative":2,"neutral":1,"mixed":0}',
 '[{"topic":"CSV import","count":2},{"topic":"performance","count":1}]',
 '["Intuitive dashboard"]',
 '["CSV failures","Slow processing"]',
 '["Improve CSV validation","Optimize processing"]',
 'Users appreciate usability but report import and performance issues.'
),
(
 '80000000-0000-4000-8000-000000000002',
 '20000000-0000-4000-8000-000000000002',
 '60000000-0000-4000-8000-000000000002',
 4, 1, 1, 0, 1, 3.50,
 '{"positive":1,"negative":1,"neutral":0,"mixed":1}',
 '[{"topic":"visualizations","count":2},{"topic":"API documentation","count":1}]',
 '["Clear visualizations","Responsive support"]',
 '["Confusing API documentation"]',
 '["Simplify integrations","Improve API documentation"]',
 'Visualizations are valued; integration setup and documentation need work.'
)
ON CONFLICT DO NOTHING;

-- 11. Recommendations
INSERT INTO public.recommendations
    (id, project_id, analysis_run_id, title, description,
     category, priority, status)
VALUES
(
 '90000000-0000-4000-8000-000000000001',
 '20000000-0000-4000-8000-000000000001',
 '60000000-0000-4000-8000-000000000001',
 'Improve CSV import validation',
 'Detect unsupported characters and show row-level validation errors before import.',
 'reliability', 'high', 'open'
),
(
 '90000000-0000-4000-8000-000000000002',
 '20000000-0000-4000-8000-000000000001',
 '60000000-0000-4000-8000-000000000001',
 'Optimize large dataset processing',
 'Profile processing bottlenecks and process large datasets in batches.',
 'performance', 'high', 'open'
),
(
 '90000000-0000-4000-8000-000000000003',
 '20000000-0000-4000-8000-000000000002',
 '60000000-0000-4000-8000-000000000002',
 'Improve API documentation',
 'Add a quick-start guide and practical request/response examples.',
 'documentation', 'medium', 'open'
),
(
 '90000000-0000-4000-8000-000000000004',
 '20000000-0000-4000-8000-000000000002',
 '60000000-0000-4000-8000-000000000002',
 'Simplify integration setup',
 'Provide guided configuration and clearer setup error messages.',
 'usability', 'medium', 'open'
)
ON CONFLICT DO NOTHING;

-- 12. Recommendation evidence
INSERT INTO public.recommendation_evidence
    (id, recommendation_id, feedback_record_id,
     feedback_analysis_id, evidence_type, relevance_score, rationale)
VALUES
(
 '91000000-0000-4000-8000-000000000001',
 '90000000-0000-4000-8000-000000000001',
 '40000000-0000-4000-8000-000000000002',
 '70000000-0000-4000-8000-000000000002',
 'supporting', 0.98,
 'The customer explicitly reports CSV import failures.'
),
(
 '91000000-0000-4000-8000-000000000002',
 '90000000-0000-4000-8000-000000000001',
 '40000000-0000-4000-8000-000000000004',
 '70000000-0000-4000-8000-000000000004',
 'contextual', 0.65,
 'The customer asks for more export options.'
),
(
 '91000000-0000-4000-8000-000000000003',
 '90000000-0000-4000-8000-000000000002',
 '40000000-0000-4000-8000-000000000003',
 '70000000-0000-4000-8000-000000000003',
 'supporting', 0.99,
 'The customer directly reports slow large-dataset processing.'
),
(
 '91000000-0000-4000-8000-000000000004',
 '90000000-0000-4000-8000-000000000003',
 '40000000-0000-4000-8000-000000000007',
 '70000000-0000-4000-8000-000000000007',
 'supporting', 0.97,
 'The customer reports confusing and incomplete API docs.'
),
(
 '91000000-0000-4000-8000-000000000005',
 '90000000-0000-4000-8000-000000000004',
 '40000000-0000-4000-8000-000000000006',
 '70000000-0000-4000-8000-000000000006',
 'supporting', 0.91,
 'The customer reports difficult integration configuration.'
),
(
 '91000000-0000-4000-8000-000000000006',
 '90000000-0000-4000-8000-000000000003',
 '40000000-0000-4000-8000-000000000005',
 '70000000-0000-4000-8000-000000000005',
 'contextual', 0.35,
 'Positive feedback about reporting provides context for prioritization.'
),
(
 '91000000-0000-4000-8000-000000000007',
 '90000000-0000-4000-8000-000000000002',
 '40000000-0000-4000-8000-000000000001',
 '70000000-0000-4000-8000-000000000001',
 'contextual', 0.30,
 'Positive usability feedback is context, not direct performance evidence.'
),
(
 '91000000-0000-4000-8000-000000000008',
 '90000000-0000-4000-8000-000000000001',
 '40000000-0000-4000-8000-000000000008',
 '70000000-0000-4000-8000-000000000008',
 'supporting', 0.82,
 'A second analysis record also identifies import errors.'
)
ON CONFLICT DO NOTHING;

COMMIT;

-- Verify the inserted sample data.
SELECT 'organizations' AS table_name, count(*) AS rows
FROM public.organizations
WHERE slug = 'feedbackiq-sql-practice'
UNION ALL
SELECT 'projects', count(*)
FROM public.projects
WHERE organization_id = '10000000-0000-4000-8000-000000000001'
UNION ALL
SELECT 'documents', count(*)
FROM public.documents
WHERE id IN (
    '30000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000002'
)
UNION ALL
SELECT 'feedback_records', count(*)
FROM public.feedback_records
WHERE document_id IN (
    '30000000-0000-4000-8000-000000000001',
    '30000000-0000-4000-8000-000000000002'
);

/*
Count projects per organization
Count feedback records per project
Find average rating per project
Count positive, negative and neutral feedback per project
Find projects with more than one negative review
Show every recommendation with its supporting feedback text
Find the most common feedback topics
Rank feedback by negative sentiment score within each project
Find projects that have no recommendations
Show each project's latest analysis run

*/