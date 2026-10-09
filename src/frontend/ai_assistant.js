/**
 * Multimodal AI Agent Voice & Chat Assistant for UHI Protocol
 * Uses Web Speech API for voice recognition (STT) and voice speech synthesis (TTS).
 */
class UhiAiAssistant {
  constructor(chatBodyId, inputId, micBtnId, sendBtnId) {
    this.chatBody = document.getElementById(chatBodyId);
    this.input = document.getElementById(inputId);
    this.micBtn = document.getElementById(micBtnId);
    this.sendBtn = document.getElementById(sendBtnId);
    this.isRecording = false;

    this.initSpeech();
    this.bindEvents();
  }

  initSpeech() {
    // Check SpeechRecognition support
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
    if (SpeechRecognition) {
      this.recognition = new SpeechRecognition();
      this.recognition.continuous = false;
      this.recognition.interimResults = false;
      this.recognition.lang = 'en-US';

      this.recognition.onstart = () => {
        this.isRecording = true;
        this.micBtn.classList.add('recording');
      };

      this.recognition.onresult = (event) => {
        const transcript = event.results[0][0].transcript;
        this.input.value = transcript;
        this.handleSend();
      };

      this.recognition.onerror = (e) => {
        console.warn('Speech recognition error:', e);
        this.stopRecording();
      };

      this.recognition.onend = () => {
        this.stopRecording();
      };
    } else {
      this.micBtn.style.opacity = '0.5';
      this.micBtn.title = 'Speech Recognition not supported in this browser';
    }
  }

  stopRecording() {
    this.isRecording = false;
    this.micBtn.classList.remove('recording');
  }

  speak(text) {
    if ('speechSynthesis' in window) {
      window.speechSynthesis.cancel();
      const utterance = new SpeechSynthesisUtterance(text);
      utterance.rate = 1.05;
      utterance.pitch = 1.0;
      window.speechSynthesis.speak(utterance);
    }
  }

  bindEvents() {
    this.sendBtn.addEventListener('click', () => this.handleSend());
    this.input.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') this.handleSend();
    });

    this.micBtn.addEventListener('click', () => {
      if (!this.recognition) {
        alert('Voice recognition is not supported in this browser.');
        return;
      }
      if (this.isRecording) {
        this.recognition.stop();
      } else {
        try {
          this.recognition.start();
        } catch (err) {
          console.warn('Recognition start error:', err);
        }
      }
    });
  }

  appendMessage(text, isAi = false) {
    const msgDiv = document.createElement('div');
    msgDiv.className = `chat-msg ${isAi ? 'ai-msg' : 'user-msg'}`;
    const bubble = document.createElement('div');
    bubble.className = 'msg-bubble';
    bubble.innerText = text;
    msgDiv.appendChild(bubble);
    this.chatBody.appendChild(msgDiv);
    this.chatBody.scrollTop = this.chatBody.scrollHeight;
  }

  handleSend() {
    const text = this.input.value.trim();
    if (!text) return;

    this.appendMessage(text, false);
    this.input.value = '';

    // Generate intelligent AI response
    setTimeout(() => {
      const response = this.computeAiResponse(text);
      this.appendMessage(response, true);
      this.speak(response);
    }, 400);
  }

  computeAiResponse(query) {
    const q = query.toLowerCase();

    if (q.includes('elon') || q.includes('uhi') || q.includes('universal high income') || q.includes('salary')) {
      return "Elon Musk envisions Universal High Income (UHI) as the inevitable economic structure of a post-scarcity society. Unlike basic UBI which merely combats poverty, UHI distributes high purchasing power funded by autonomous AI fleets and humanoid robotics like Tesla Optimus, achieving deflationary abundance without inflation.";
    }

    if (q.includes('x402') || q.includes('bazaar') || q.includes('tax')) {
      return "The x402 Bazaar Protocol enables autonomous machine-to-machine commerce using HTTP 402 'Payment Required'. Every time an autonomous AI agent or robotics service executes a task, a 10% protocol tax is automatically routed directly to the UHI Treasury Canister.";
    }

    if (q.includes('conway') || q.includes('automaton') || q.includes('entropy') || q.includes('multiplier')) {
      return "The Conway Automaton Engine runs a 16x16 cellular state machine on-chain. Active living cells represent decentralized computing nodes in Web 4.0. The living cell density directly computes cryptographic entropy and scales the UHI payout multiplier between 1.0x and 1.5x!";
    }

    if (q.includes('pqc') || q.includes('quantum') || q.includes('security')) {
      return "The PQC Layer integrates NIST FIPS 203 (ML-KEM-768) and FIPS 204 (ML-DSA-65) lattice cryptography. This ensures that treasury custody and UHI dividend claims are completely immune to Shor's algorithm and future quantum computers.";
    }

    if (q.includes('token') || q.includes('supply') || q.includes('tokenomics') || q.includes('unlimited')) {
      return "UHI Tokenomics adopts Productivity-Backed Elastic Emission on ICRC-1/2 standards. Instead of arbitrary hyperinflation, new UHI is minted strictly against verified AI compute settlements in the x402 bazaar, balanced by deflationary fee burning.";
    }

    if (q.includes('claim') || q.includes('how to')) {
      return "To claim your UHI dividend: 1) Connect your Internet Identity or Plug wallet, 2) Verify your PQC lattice signature, and 3) Click 'Claim Universal High Income Now'. Thanks to ICP's Reverse Gas Model, claiming is 100% gas-free for human citizens!";
    }

    return "The UHI Protocol is synchronized on Internet Computer (ICP). We fuse autonomous AI taxation (x402), Web 4.0 cellular state engines (Conway), and Post-Quantum Cryptography to guarantee universal human dividends in an automated world.";
  }
}

window.UhiAiAssistant = UhiAiAssistant;
