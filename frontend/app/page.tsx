"use client";

import { useEffect, useState } from "react";
import { ethers } from "ethers";

const VAULT_ABI = [
  "function stake(uint256 amount)",
  "function unstake(uint256 amount)",
  "function claim()",
  "function balanceOf(address) view returns (uint256)",
];

const ERC20_ABI = [
  "function balanceOf(address) view returns (uint256)",
  "function approve(address spender, uint256 amount) returns (bool)",
];

export default function Home() {
  const [account, setAccount] = useState<string>("");
  const [stakeBalance, setStakeBalance] = useState<string>("0");
  const [tokenBalance, setTokenBalance] = useState<string>("0");
  const [amount, setAmount] = useState<string>("0");

  const rpcUrl = process.env.NEXT_PUBLIC_RPC_URL!;
  const stakeToken = process.env.NEXT_PUBLIC_STAKE_TOKEN!;
  const vault = process.env.NEXT_PUBLIC_VAULT!;

  const provider = new ethers.JsonRpcProvider(rpcUrl);

  async function connect() {
    if (!window.ethereum) return alert("MetaMask not found");
    const accounts = await window.ethereum.request({ method: "eth_requestAccounts" });
    setAccount(accounts[0]);
  }

  async function refresh() {
    if (!account) return;
    const token = new ethers.Contract(stakeToken, ERC20_ABI, provider);
    const v = new ethers.Contract(vault, VAULT_ABI, provider);
    const [bal, staked] = await Promise.all([
      token.balanceOf(account),
      v.balanceOf(account),
    ]);
    setTokenBalance(bal.toString());
    setStakeBalance(staked.toString());
  }

  async function stake() {
    if (!window.ethereum) return;
    const signer = await new ethers.BrowserProvider(window.ethereum).getSigner();
    const token = new ethers.Contract(stakeToken, ERC20_ABI, signer);
    const v = new ethers.Contract(vault, VAULT_ABI, signer);
    const amt = BigInt(amount);
    await (await token.approve(vault, amt)).wait();
    await (await v.stake(amt)).wait();
    refresh();
  }

  async function unstake() {
    if (!window.ethereum) return;
    const signer = await new ethers.BrowserProvider(window.ethereum).getSigner();
    const v = new ethers.Contract(vault, VAULT_ABI, signer);
    const amt = BigInt(amount);
    await (await v.unstake(amt)).wait();
    refresh();
  }

  async function claim() {
    if (!window.ethereum) return;
    const signer = await new ethers.BrowserProvider(window.ethereum).getSigner();
    const v = new ethers.Contract(vault, VAULT_ABI, signer);
    await (await v.claim()).wait();
    refresh();
  }

  useEffect(() => {
    refresh();
  }, [account]);

  return (
    <main style={{ maxWidth: 680, margin: "40px auto", fontFamily: "Inter, sans-serif" }}>
      <h1>Uniswap v4 Hook Staking</h1>
      <p>Stake token → earn hook fees.</p>

      {!account ? (
        <button onClick={connect}>Connect Wallet</button>
      ) : (
        <div>
          <div>Account: {account}</div>
          <div>Token balance: {tokenBalance}</div>
          <div>Staked: {stakeBalance}</div>
        </div>
      )}

      <hr />

      <div>
        <input value={amount} onChange={(e) => setAmount(e.target.value)} />
        <button onClick={stake}>Stake</button>
        <button onClick={unstake} style={{ marginLeft: 8 }}>Unstake</button>
        <button onClick={claim} style={{ marginLeft: 8 }}>Claim</button>
      </div>
    </main>
  );
}
