-- 1) The table you fill with questions (one question per row)
create table if not exists question_rows (
  id bigint generated always as identity primary key,
  subject text not null,
  active boolean not null default true,
  q_en text not null, q_hi text, q_bn text,
  a_en text not null, b_en text not null, c_en text not null, d_en text not null,
  a_hi text, b_hi text, c_hi text, d_hi text,
  a_bn text, b_bn text, c_bn text, d_bn text,
  correct int not null check (correct between 0 and 3),
  exp_en text not null default '', exp_hi text, exp_bn text,
  created_at timestamptz not null default now()
);

-- 2) Students may read active questions (nobody can change them from the app)
alter table question_rows enable row level security;
grant select on question_rows to anon, authenticated;
create policy "students read active questions" on question_rows
  for select to anon, authenticated using (active);

-- 3) The view the app reads: turns the four options into a list
create or replace view questions with (security_invoker = on) as
select
  id, subject, active, q_en, q_hi, q_bn,
  jsonb_build_array(a_en, b_en, c_en, d_en) as opts,
  case when a_hi is null or b_hi is null or c_hi is null or d_hi is null
       then null else jsonb_build_array(a_hi, b_hi, c_hi, d_hi) end as opts_hi,
  case when a_bn is null or b_bn is null or c_bn is null or d_bn is null
       then null else jsonb_build_array(a_bn, b_bn, c_bn, d_bn) end as opts_bn,
  correct, exp_en, exp_hi, exp_bn
from question_rows;
grant select on questions to anon, authenticated;
