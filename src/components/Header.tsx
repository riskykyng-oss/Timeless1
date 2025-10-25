import { ShoppingCart } from 'lucide-react';
import { CartItem } from '../lib/supabase';

interface HeaderProps {
  cart: CartItem[];
  onCartClick: () => void;
}

export default function Header({ cart, onCartClick }: HeaderProps) {
  const cartCount = cart.reduce((sum, item) => sum + item.quantity, 0);

  return (
    <header className="header">
      <div className="header-container">
        <div className="logo">
          <h1>Fashion Boutique</h1>
        </div>
        <button className="cart-button" onClick={onCartClick}>
          <ShoppingCart size={24} />
          {cartCount > 0 && <span className="cart-badge">{cartCount}</span>}
        </button>
      </div>
    </header>
  );
}
