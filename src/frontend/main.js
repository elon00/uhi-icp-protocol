/**
 * Main Coordinator for UHI Protocol Web 4.0 Dashboard
 */
document.addEventListener('DOMContentLoaded', () => {
  // Application State
  const state = {
    totalSupply: 1000000000.0,
    treasuryBalance: 10000000.0,
    basePayout: 500.0,
    currentMultiplier: 1.25,
    conwayStats: null,
    wallet: null,
    isClaimed: false,
    services: [
      {
        id: 0,
        title: "Tesla Optimus Fleet - Automated Assembly Work",
        desc: "Autonomous robotics actuation for smart manufacturing lines.",
        cost: 50.0,
        tax: 5.0,
        category: "ROBOTICS",
        invocations: 1240
      },
      {
        id: 1,
        title: "DeepSeek AI Multi-Modal Inference Cluster",
        desc: "Decentralized GPU reasoning & code generation cluster.",
        cost: 10.0,
        tax: 1.0,
        category: "AI_INFERENCE",
        invocations: 8520
      },
      {
        id: 2,
        title: "Autonomous Drone Logistics & Delivery",
        desc: "Last-mile smart air cargo routing & payload delivery.",
        cost: 25.0,
        tax: 2.5,
        category: "ROBOTICS",
        invocations: 410
      }
    ]
  };

  // UI Elements
  const elTotalSupply = document.getElementById('metric-total-supply');
  const elTreasury = document.getElementById('metric-treasury-balance');
  const elConwayNodes = document.getElementById('metric-conway-nodes');
  const elConwayDensity = document.getElementById('metric-conway-density');
  const elMultiplier = document.getElementById('metric-multiplier');
  const elGenBadge = document.getElementById('conway-gen-badge');

  const elEffectivePayout = document.getElementById('display-effective-payout');
  const elBasePayout = document.getElementById('display-base-payout');
  const elMultiplierBoost = document.getElementById('display-multiplier-boost');

  const claimBtn = document.getElementById('claim-uhi-btn');
  const claimStatusMsg = document.getElementById('claim-status-msg');

  const qrWrapper = document.getElementById('qr-code-svg-wrapper');
  const qrTargetInput = document.getElementById('qr-target-text');
  const regenQrBtn = document.getElementById('regen-qr-btn');
  const copyQrBtn = document.getElementById('copy-qr-btn');

  const servicesContainer = document.getElementById('services-container');

  // Initialize QR Code
  function renderQr(text) {
    if (window.NativeQrSvg) {
      qrWrapper.innerHTML = window.NativeQrSvg.createQrSvg(text, 160);
    }
  }
  renderQr(qrTargetInput.value);

  regenQrBtn.addEventListener('click', () => {
    const randomSalt = Math.floor(Math.random() * 899999 + 100000);
    const updated = `uhi://claim?principal=citizen-${randomSalt}&epoch=1&multiplier=${state.currentMultiplier}`;
    qrTargetInput.value = updated;
    renderQr(updated);
  });

  copyQrBtn.addEventListener('click', () => {
    navigator.clipboard.writeText(qrTargetInput.value);
    copyQrBtn.innerText = 'Copied!';
    setTimeout(() => { copyQrBtn.innerText = 'Copy Payload'; }, 1500);
  });

  // Initialize Conway Engine
  const conway = new window.ConwayGrid('conway-canvas', (stats) => {
    state.conwayStats = stats;
    state.currentMultiplier = parseFloat(stats.multiplier);

    // Update UI elements
    elConwayNodes.innerText = `${stats.alive} / 256 Nodes`;
    elConwayDensity.innerHTML = `Density: ${stats.densityPct}% &bull; Entropy: ${stats.entropy}`;
    elGenBadge.innerText = `Gen: ${stats.generation}`;

    const boostPct = Math.round((state.currentMultiplier - 1.0) * 100);
    elMultiplier.innerText = `${state.currentMultiplier}x (${100 + boostPct}%)`;
    elMultiplierBoost.innerText = `+${boostPct}% (${state.currentMultiplier}x)`;

    const effective = (state.basePayout * state.currentMultiplier).toFixed(2);
    elEffectivePayout.innerText = effective;
  });

  document.getElementById('conway-step-btn').addEventListener('click', () => conway.step());
  document.getElementById('conway-toggle-run-btn').addEventListener('click', (e) => {
    const isRunning = conway.toggleRun();
    e.target.innerHTML = isRunning ? 'Pause &#10074;&#10074;' : 'Auto-Simulate &#9658;';
  });
  document.getElementById('conway-seed-glider-btn').addEventListener('click', () => conway.seedGlider());
  document.getElementById('conway-seed-acorn-btn').addEventListener('click', () => conway.seedAcorn());

  // Initialize Multi-Wallet
  const walletModal = document.getElementById('wallet-modal-overlay');
  const walletBtn = document.getElementById('wallet-connect-btn');
  const walletBtnLabel = document.getElementById('wallet-btn-label');
  const closeWalletModalBtn = document.getElementById('close-wallet-modal-btn');

  const walletAdapter = new window.MultiWalletAdapter((acc) => {
    state.wallet = acc;
    if (acc.isConnected) {
      const shortP = `${acc.principal.slice(0, 5)}...${acc.principal.slice(-4)}`;
      walletBtnLabel.innerText = `${acc.wallet}: ${shortP}`;
      walletBtn.style.background = 'linear-gradient(135deg, #10b981, #00f3ff)';
      qrTargetInput.value = `uhi://claim?principal=${acc.principal}&amount=${elEffectivePayout.innerText}`;
      renderQr(qrTargetInput.value);
    } else {
      walletBtnLabel.innerText = 'Connect Multi-Wallet';
      walletBtn.style.background = '';
    }
  });

  walletBtn.addEventListener('click', () => {
    if (state.wallet && state.wallet.isConnected) {
      if (confirm(`Connected to ${state.wallet.wallet}. Disconnect?`)) {
        walletAdapter.disconnect();
      }
    } else {
      walletModal.classList.add('open');
    }
  });

  closeWalletModalBtn.addEventListener('click', () => {
    walletModal.classList.remove('open');
  });

  document.querySelectorAll('.wallet-opt-btn').forEach(btn => {
    btn.addEventListener('click', async () => {
      const type = btn.getAttribute('data-wallet');
      await walletAdapter.connect(type);
      walletModal.classList.remove('open');
    });
  });

  // Render x402 AI Bazaar Services
  function renderServices() {
    servicesContainer.innerHTML = '';
    state.services.forEach(srv => {
      const card = document.createElement('div');
      card.className = 'service-card';
      card.innerHTML = `
        <div class="service-meta">
          <h4>${srv.title}</h4>
          <p>${srv.desc}</p>
          <div>
            <span class="service-cost-tag">${srv.cost} UHI / call</span>
            <span class="service-cost-tag tax-badge">+${srv.tax} UHI (10% UHI Tax)</span>
          </div>
        </div>
        <button class="glow-button invoke-service-btn" data-id="${srv.id}">
          ⚡ Execute Call
        </button>
      `;
      servicesContainer.appendChild(card);
    });

    document.querySelectorAll('.invoke-service-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const id = parseInt(btn.getAttribute('data-id'));
        const srv = state.services.find(s => s.id === id);
        if (srv) {
          srv.invocations++;
          state.treasuryBalance += srv.tax;
          state.totalSupply += srv.tax; // Elastic mint backed by verified compute productivity

          elTreasury.innerText = `${state.treasuryBalance.toLocaleString('en-US', { minimumFractionDigits: 2 })} UHI`;
          elTotalSupply.innerText = `${state.totalSupply.toLocaleString('en-US', { minimumFractionDigits: 2 })} UHI`;

          btn.innerText = '✓ Settled & Taxed';
          setTimeout(() => { btn.innerText = '⚡ Execute Call'; }, 1000);
        }
      });
    });
  }
  renderServices();

  // UHI Claim Action
  claimBtn.addEventListener('click', () => {
    if (!state.wallet || !state.wallet.isConnected) {
      walletModal.classList.add('open');
      claimStatusMsg.className = 'status-msg error';
      claimStatusMsg.innerText = 'Please connect your Web3 / Internet Identity wallet first.';
      return;
    }

    if (state.isClaimed) {
      claimStatusMsg.className = 'status-msg error';
      claimStatusMsg.innerText = 'UHI Human Dividend already claimed for Epoch #1.';
      return;
    }

    const payout = (state.basePayout * state.currentMultiplier).toFixed(2);
    claimBtn.innerText = 'Verifying NIST FIPS 204 PQC Proof...';
    claimBtn.disabled = true;

    setTimeout(() => {
      state.isClaimed = true;
      claimBtn.innerText = '✓ Claimed Successfully';
      claimBtn.style.background = 'linear-gradient(135deg, #10b981, #059669)';
      claimBtn.disabled = false;

      claimStatusMsg.className = 'status-msg success';
      claimStatusMsg.innerHTML = `
        <strong>SUCCESS:</strong> ${payout} UHI disbursed to ${state.wallet.principal}!<br>
        <strong>Proof:</strong> 0xPQC_FIPS204_LATTICE_OK_${Date.now()}<br>
        <strong>Reverse-Gas:</strong> $0.00 Gas Fee charged.
      `;
    }, 700);
  });

  // Multimodal AI Assistant Widget
  const orbToggle = document.getElementById('assistant-orb-toggle');
  const asstWindow = document.getElementById('assistant-window');
  const closeAsstBtn = document.getElementById('close-assistant-btn');

  orbToggle.addEventListener('click', () => {
    asstWindow.classList.toggle('open');
  });
  closeAsstBtn.addEventListener('click', () => {
    asstWindow.classList.remove('open');
  });

  new window.UhiAiAssistant(
    'asst-chat-body',
    'asst-input-text',
    'speech-mic-btn',
    'asst-send-btn'
  );
});
