# Contract Test Registry

> **Owner**: lead-programmer
> **Updated**: Whenever a seam is added, removed, or has its contract version changed.
>
> This file indexes all contract tests in `production/contract-tests/`.
> Protocol: `.claude/docs/contract-testing-protocol.md`

---

## What Is a Contract Test?

A contract test verifies that the provider of a seam emits output that matches the
registered signature, and that each consumer correctly reads that output using only
the fields the contract defines. Contract tests are narrow, isolated, and runnable
without a full engine scene.

---

## Registry

| Seam ID | Directory | Provider | Consumers | Contract Version | Last Run |
|---------|-----------|----------|-----------|-----------------|----------|
| *(none yet)* | — | — | — | — | — |

---

## Adding an Entry

When a new seam is registered in `memory/evergreen/core-interfaces.md`:

1. Create directory: `production/contract-tests/[SEAM-ID]--[system-a]--[system-b]--[seam-name]/`
2. Create `contract.md` inside it (use the template in `.claude/docs/contract-testing-protocol.md`)
3. Create `test_provider.[ext]` and `test_consumer_[name].[ext]` stubs
4. Add a row to the table above
5. Add the new contract test path to `production/test-impact-map.md` under the relevant seam entry

---

## Contract Version Policy

The contract version in `contract.md` must always match the version in the corresponding
`memory/evergreen/core-interfaces.md` entry. If they differ, the seam drift detection
script will warn and the integration sprint team will flag it as a contract sync issue.
