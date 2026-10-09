/**
 * Multi-Wallet Adapter for UHI Protocol (ICP Web 4.0)
 * Supports: Internet Identity, Plug, NFID, Stoic, Bitfinity
 */
class MultiWalletAdapter {
  constructor(onAccountChanged) {
    this.currentWallet = null;
    this.principal = null;
    this.isConnected = false;
    this.onAccountChanged = onAccountChanged;
  }

  async connect(walletType) {
    try {
      if (walletType === 'plug') {
        if (window.ic && window.ic.plug) {
          const connected = await window.ic.plug.requestConnect();
          if (connected) {
            this.principal = (await window.ic.plug.getPrincipal()).toString();
            this.currentWallet = 'Plug';
            this.isConnected = true;
          }
        } else {
          throw new Error('Plug wallet extension is unavailable. No simulated connection permitted.');
        }
      } else {
        throw new Error(walletType + ' requires an authenticated wallet integration; no synthetic principals permitted.');
      }

      if (this.onAccountChanged) {
        this.onAccountChanged({
          wallet: this.currentWallet,
          principal: this.principal,
          isConnected: this.isConnected
        });
      }

      if (!this.isConnected || !this.principal) throw new Error('Wallet authentication did not complete.');
      return { success: true, principal: this.principal };
    } catch (err) {
      console.error('Wallet connection error:', err);
      return { success: false, error: err.message };
    }
  }

  disconnect() {
    this.currentWallet = null;
    this.principal = null;
    this.isConnected = false;
    if (this.onAccountChanged) {
      this.onAccountChanged({
        wallet: null,
        principal: null,
        isConnected: false
      });
    }
  }
}

window.MultiWalletAdapter = MultiWalletAdapter;
