# Prompt templates (P = 5), written by the author; {TITLE} is replaced by the bill title

P1 (bare)
Is the following US congressional bill primarily about health? Bill title: "{TITLE}"
Answer with a single digit: 1 for yes, 0 for no.

P2 (codebook)
You are coding US congressional bills by policy topic using the Comparative Agendas Project scheme. The topic "Health" (code 3) covers health care, health insurance, drugs and pharmaceuticals, medical facilities, mental health, disease prevention and health research. Does the bill below belong to this topic as its main subject?
Title: "{TITLE}"  Reply 1 (yes) or 0 (no) only.

P3 (contrast)
A bill's main subject can be health, or one of twenty other policy areas such as the economy, defence, education, the environment or law. Consider the title and decide whether its main subject is health.  "{TITLE}"  Output only 1 or 0.

P4 (role)
As an experienced legislative analyst, classify this bill title. Output 1 if the bill's primary purpose concerns health policy, 0 otherwise. Title: "{TITLE}"

P5 (reasoned)
Read the bill title, identify its primary policy purpose in your own words, then decide whether that purpose falls under health. Give only the final digit, 1 = health, 0 = not health. Title: "{TITLE}"
