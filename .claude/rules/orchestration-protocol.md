# Orchestration Protocol

When handling complex or multi-step developer requests:

1. **Deconstruct Request**: Break down task into distinct phases (e.g. data layer -> domain model -> presentation -> tests).
2. **Context Inspection**: Read existing code, providers, tests, and documentation before making changes.
3. **Incremental Implementation**: Apply surgical changes iteratively.
4. **Automated Verification**: Validate after each major phase using `flutter analyze` and `flutter test`.
5. **Report & Update Docs**: Keep `docs/` in sync with codebase evolution.
