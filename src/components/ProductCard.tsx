import { Product } from '../lib/supabase';

interface ProductCardProps {
  product: Product;
  onProductClick: (product: Product) => void;
}

export default function ProductCard({ product, onProductClick }: ProductCardProps) {
  return (
    <div className="product-card" onClick={() => onProductClick(product)}>
      <div className="product-image-wrapper">
        <img src={product.image_url} alt={product.name} className="product-image" />
        {!product.in_stock && <div className="out-of-stock-badge">Out of Stock</div>}
      </div>
      <div className="product-info">
        <h3 className="product-name">{product.name}</h3>
        <p className="product-price">${product.price.toFixed(2)}</p>
      </div>
    </div>
  );
}
