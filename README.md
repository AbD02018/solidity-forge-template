<div align="center">

# ⚒️ solidity-forge-template

### *Production-grade Foundry template for fork-based smart contract PoCs.*

[![Foundry](https://img.shields.io/badge/Foundry-required-000000?style=flat-square)](https://book.getfoundry.sh/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.22-363636?style=flat-square&logo=solidity&logoColor=white)](https://soliditylang.org/)
[![Chains](https://img.shields.io/badge/supported%20chains-5-blueviolet?style=flat-square)](#-supported-fork-chains)
[![PoC Patterns](https://img.shields.io/badge/PoC%20patterns-12-success?style=flat-square)](#-poc-patterns-included)
[![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)](LICENSE)

</div>

---

## 🎯 Why

> *"I need to prove this bug exists on mainnet — in under 30 minutes."*

That's the workflow `solidity-forge-template` is built for. It's the **battle-tested** template I use to write mainnet-fork-based Proof of Concepts for bug bounty submissions. It's been used to find and validate multi-million dollar bug reports.

The default Foundry template gets you 30% of the way. This gets you the other 70%: pre-configured RPCs, fork helpers, state-diff utilities, OZ versions that match common audit-period deployments, and 12 ready-to-use PoC patterns covering 90% of DeFi bug types.

---

## ⚡ Quick Start

### Use as a template

```bash
forge init my-poc --template AbD02018/solidity-forge-template
cd my-poc
forge install
cp .env.example .env
# Fill in your RPC URLs (Alchemy, Infura, public nodes)
forge test --fork-url $ETH_RPC_URL -vvv
```

### Use as a library

```bash
forge install AbD02018/solidity-forge-template --no-commit
```

```solidity
import "solidity-forge-template/src/ForkHelpers.sol";
import "solidity-forge-template/src/StateDiff.sol";

contract MyPoC is Test {
    function test_Exploit() public {
        forkMainnet(ETH_BLOCK);
        // ... your exploit here
        assertGt(attacker.balance, INITIAL, "exploit didn't pay");
    }
}
```

---

## ✨ What's Included

### Core
- **Pre-configured Foundry project** — solc 0.8.22, optimizer 200 runs
- **Multi-chain fork helpers** — `forkMainnet()`, `forkArbitrum()`, `forkBase()`, `forkOptimism()`, `forkInk()`
- **OpenZeppelin v4.9.6** + upgradeable v4.9 (release-v4.9 branch — for Nado-style projects)
- **OpenZeppelin v5.x** as an alternate (for newer protocols)
- **forge-std** with all cheatcodes
- **Foundry cheatcode extension** — `vm.snapshotState()`, `vm.rollbackState()`, custom log formatters

### State Diff Utilities
- `StateDiff.diff(address target, bytes32[] memory slots)` — Capture storage slot-by-slot
- `StateDiff.balanceDiff(address token, address from, address to)` — Track ERC-20 flow
- `FundImpact.formatWei(uint256 amount)` — Pretty-print with USD conversion (via Chainlink feeds)

### PoC Patterns (12 ready-to-use templates)

| # | Pattern | What it tests |
|---|---|---|
| 01 | **Liquidation** | Borrow position → trigger liquidation → compute seizable amount |
| 02 | **Oracle Manipulation** | Spot oracle + flash loan → price manipulation → exploit |
| 03 | **Fund Conservation** | Deposit/withdraw loop → assert no value lost to rounding |
| 04 | **Governance Attack** | Flash-loan votes → pass malicious proposal |
| 05 | **Reentrancy** | Single-function + cross-function reentrancy |
| 06 | **Access Control Bypass** | Direct call to admin function with no auth |
| 07 | **Proxy Upgrade** | Upgrade to malicious implementation |
| 08 | **Signature Replay** | EIP-712 signature replay across chains/domains |
| 09 | **First Deposit Inflation** | ERC-4626 vault inflation via tiny first deposit |
| 10 | **Cross-chain Replay** | Bridge payload replay on destination chain |
| 11 | **Storage Collision** | Proxy storage layout collision |
| 12 | **Arithmetic Edge** | Edge cases at type boundaries (0, max, 1 wei over) |

### CI/CD

- **GitHub Actions workflow** — Runs all PoCs on every PR
- **Slither + Aderyn integration** — Static analysis on every commit
- **Coverage report** — Auto-uploaded to codecov

---

## 🌐 Supported Fork Chains

| Chain | ID | Helper | Default RPC Env Var |
|---|---|---|---|
| **Ethereum** | 1 | `forkMainnet(block)` | `ETH_RPC_URL` |
| **Arbitrum One** | 42161 | `forkArbitrum(block)` | `ARB_RPC_URL` |
| **Base** | 8453 | `forkBase(block)` | `BASE_RPC_URL` |
| **Optimism** | 10 | `forkOptimism(block)` | `OP_RPC_URL` |
| **Ink** | 57073 | `forkInk(block)` | `INK_RPC_URL` |

Need another chain? Open an issue — most are a 5-line change.

---

## 🧪 Example: Liquidation PoC in 30 Lines

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "forge-std/Test.sol";
import "solidity-forge-template/src/ForkHelpers.sol";
import "solidity-forge-template/src/StateDiff.sol";

interface ILendingMarket {
    function liquidate(address borrower, uint256 repayAmount) external;
    function getCollateralValue(address borrower) external view returns (uint256);
    function getDebtValue(address borrower) external view returns (uint256);
}

contract LiquidationPoC is Test {
    ILendingMarket market = ILendingMarket(MARKET_ADDR);
    address borrower = 0xB0RR0W3R;
    address attacker = address(0xA77AC);

    function test_Liquidate() public {
        forkMainnet(BLOCK);
        deal(USDC, attacker, INITIAL_FUNDS);

        uint256 crBefore = market.getCollateralValue(borrower) * 1e18 
                          / market.getDebtValue(borrower);
        emit log_named_uint("CR before", crBefore);

        vm.startPrank(attacker);
        market.liquidate(borrower, REPAY_AMOUNT);
        vm.stopPrank();

        uint256 crAfter = market.getCollateralValue(borrower) * 1e18 
                         / market.getDebtValue(borrower);
        emit log_named_uint("CR after", crAfter);

        StateDiff.diff(address(market), slots);
    }
}
```

---

## 🛠️ Why This Template

| Compared to vanilla `forge init` | This template |
|---|---|
| No multi-chain helpers | `forkArbitrum()`, `forkBase()`, etc. pre-wired |
| OZ only at latest | Multiple OZ versions for audit-period compatibility |
| Manual state-diff | `StateDiff.diff()` + pretty-printing |
| Static analysis optional | Slither + Aderyn on every commit |
| No PoC patterns | 12 ready-to-use templates |
| Generic CI | Bug-bounty submission-ready CI |

---

## 🤝 Contributing

PRs welcome for:
- New PoC patterns (especially from 2025–2026 bug classes)
- New chain support
- Better state-diff utilities
- Documentation improvements

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 📄 License

MIT — see [LICENSE](LICENSE).

---

<div align="center">
  <sub>Built by <a href="https://github.com/AbD02018">@AbD02018</a> · Smart contract security researcher</sub>
</div>
