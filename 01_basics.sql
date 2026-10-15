
DROP TABLE IF EXISTS feedback_challenge;
DROP TABLE IF EXISTS projects_challenge;

CREATE TABLE projects_challenge (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    plan VARCHAR(20) NOT NULL
        CHECK (plan IN ('free', 'pro', 'enterprise'))
);

CREATE TABLE feedback_challenge (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    project_id BIGINT NOT NULL
        REFERENCES projects_challenge(id),
    message TEXT NOT NULL,
    sentiment VARCHAR(10) NOT NULL
        CHECK (sentiment IN ('positive', 'negative', 'neutral')),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

INSERT INTO projects_challenge (name, plan) VALUES
('FeedbackIQ', 'pro'),
('HQLogic Analytics', 'free'),
('CodeReview AI', 'enterprise'),
('ResumeAI', 'pro');

INSERT INTO feedback_challenge
(project_id, message, sentiment, rating, created_at)
VALUES
(1, 'Amazing dashboard', 'positive', 5, NOW()),
(1, 'Easy to use', 'positive', 4, NOW()),
(1, 'Reports are slow', 'negative', 2, NOW()),
(1, 'Good overall', 'positive', 4, NOW()),
(1, 'Needs better filters', 'negative', 2, NOW()),
(2, 'Nice free tool', 'positive', 5, NOW()),
(2, 'Confusing UI', 'negative', 2, NOW()),
(2, 'Average experience', 'neutral', 3, NOW()),
(3, 'Excellent analytics', 'positive', 5, NOW()),
(3, 'Great support', 'positive', 5, NOW()),
(4, 'Too many bugs', 'negative', 1, NOW()),
(4, 'Not bad', 'neutral', 3, NOW());