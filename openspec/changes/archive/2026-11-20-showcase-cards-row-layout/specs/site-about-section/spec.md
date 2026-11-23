# Spec Delta

## REMOVED Requirements

### Requirement: Other home page figures keep their sizing
**Reason**: The uniform showcase card row structure supersedes this guard. Every showcase section's figure presentation is now governed by the `site-showcase-cards` specification, so there is no "other home page figure" sizing left to protect.
**Migration**: The about treatment stays scoped to the about section through its `about__cols` grid and `#about`-scoped figure rules; showcase card presentation is owned by `site-showcase-cards`.
