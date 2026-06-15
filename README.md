# ⚒️ solidity-forge-template

> **Production-grade Foundry template for fork-based smart contract PoCs.**

Battle-tested template for writing mainnet-fork-based Proof of Concepts. Used to find and validate multi-million dollar bug reports.

---

## ✨ What's Included

- **Pre-configured Foundry project** with solc 0.8.22, optimizer 200 runs
- **Mainnet fork helpers** — `forkMainnet()`, `forkArbitrum()`, `forkBase()`, `forkOptimism()`, `forkInk()`
- **OpenZeppelin v4.9.6** + upgradeable v4.9 (release-v4.9 branch — for Nado-style projects)
- **Cheatcode library** — Extended `vm` functions for snapshot/rollback, log formatting, balance assertions
- **State diff utilities** — Capture before/after storage, compute fund impact in wei
- **12 ready-to-use PoC patterns** — liquidation, oracle manipulation, fund conservation, governance, etc.
- **CI/CD template** — GitHub Actions for running PoCs on every PR

---

## 📦 Installation

### Use as a template

```bash
forge init my-poc --template AbD02018/solidity-forge-template
cd my-poc
forge install
```

### Install in existing project

```bash
forge install AbD02018/solidity-forge-template --no-commit
```

---

## 🚀 Quick Start

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "solidity-forge-template/src/base/ForkPoCBase.sol";
import "solidity-forge-template/src/utils/StateDiff.sol";

contract MyPoC is ForkPoCBase {
    function setUp() public {
        // Fork mainnet at specific block
        vm.createSelectFork("https://eth.llamarpc.com", 19000000);
    }
    
    function test_exploit() public {
        // Read state BEFORE
        StateDiff.Snapshot memory before = StateDiff.captureState(target);
        
        // Run the exploit
        target.vulnerableFunction(attacker, maliciousInput);
        
        // Read state AFTER
        StateDiff.Snapshot memory after = StateDiff.captureState(target);
        
        // Log the impact
        StateDiff.logDiff(before, after);
        
        // Assert
        assertTrue(after.balances[attacker] > before.balances[attacker], "No profit");
    }
}
```

---

## 📂 Structure

```
solidity-forge-template/
├── src/
│   ├── base/
│   │   ├── ForkPoCBase.sol           # Base contract for fork-based PoCs
│   │   ├── MultiChainPoCBase.sol     # Cross-chain PoC base
│   │   └── FlashLoanPoCBase.sol      # Flash loan integration
│   ├── utils/
│   │   ├── StateDiff.sol             # Before/after state capture
│   │   ├── BalanceLogger.sol         # Pretty-print balance changes
│   │   ├── Events.sol                # Common event signatures
│   │   └── Addresses.sol             # Common mainnet addresses
│   ├── interfaces/
│   │   ├── IERC20Full.sol
│   │   ├── ILendingPool.sol
│   │   ├── IDex.sol
│   │   └── IOracle.sol
│   └── patterns/
│       ├── LiquidationPoC.sol
│       ├── OraclePoC.sol
│       ├── FundConservationPoC.sol
│       └── GovernancePoC.sol
├── test/
│   └── examples/
└── foundry.toml
```

---

## 🔬 Built-in Patterns

### Pattern 1: Liquidation Exploit PoC

```solidity
contract LiquidationExploitPoC is ForkPoCBase {
    function setUp() public {
        vm.createSelectFork("mainnet", 19500000);
        _setupLendingProtocol(AaveV3Mainnet.POOL);
        _seedUserWithPosition(victim, 100_000e18);
    }
    
    function test_crash_price_and_liquidate() public {
        // 1. Crash the price
        oracle.setPrice(asset, 0.5e18); // 50% drop
        
        // 2. Liquidate the victim
        uint256 profit = _liquidate(victim, attacker, asset);
        
        // 3. Profit must be material
        assertTrue(profit > 1_000e18, "Profit < $1000");
    }
}
```

### Pattern 2: Fund Conservation Break

```solidity
contract ConservationBreakPoC is ForkPoCBase {
    function test_drain() public {
        uint256 protocolBalBefore = token.balanceOf(protocol);
        // ... exploit path ...
        uint256 protocolBalAfter = token.balanceOf(protocol);
        
        assertLt(protocolBalAfter, protocolBalBefore, "No drain");
        emit log_named_uint("Loss", protocolBalBefore - protocolBalAfter);
    }
}
```

---

## ⚙️ Configuration

```toml
# foundry.toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.22"
optimizer = true
optimizer_runs = 200
evm_version = "shanghai"

[rpc_endpoints]
mainnet = "${MAINNET_RPC_URL}"
arbitrum = "${ARBITRUM_RPC_URL}"
base = "${BASE_RPC_URL}"
optimism = "${OPTIMISM_RPC_URL}"
ink = "${INK_RPC_URL}"

[fuzz]
runs = 256
```

---

## 📄 License

MIT — see [LICENSE](LICENSE)

---

<div align="center">

*Find the bug. Write the PoC. Get the bounty.*

</div>
