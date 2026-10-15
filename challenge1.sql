select name, count(f.id) as feedback_count
from projects_challenge p
left join feedback_challenge f on p.id = f.project_id
group by p.id, p.name
order by feedback_count desc;

-- Name each project and count its total feedback records. Projects with zero feedback should also be displayed in the results.