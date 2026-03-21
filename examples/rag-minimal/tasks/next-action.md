# Next Action

## Immediate Step

BA to confirm upload size limits, supported file types, and error handling
requirements before Architect designs the storage schema and API surface.
BA must document answers to the following in `tasks/ba-logic.md`:

1. Maximum file size per upload (proposed: 10 MB -- confirm or revise)
2. Supported file types (proposed: PDF and DOCX only -- confirm or revise)
3. Free plan file limit (proposed: 3 files per user on free plan -- confirm)
4. Behaviour when a user on the free plan tries to upload a 4th file:
   hard block with upgrade prompt, or soft warning?
5. Whether failed uploads count against the free plan quota

## Owner

BA

## Inputs Required

- `CLAUDE.md` -- read domain types (Document), architecture rules, and RAG config
- Product requirements stub: max 10 MB per file, PDF and DOCX only,
  3 files per user on the free plan

## Success Signal

`tasks/ba-logic.md` contains a documented decision for each of the 5 questions
above, with the owner's confirmation noted on any item that required a judgment
call.

## If Blocked

Escalate file type or size limit decisions directly to the owner. Do not let
Architect proceed with storage schema design until upload constraints are
confirmed -- schema changes after the fact are expensive.
