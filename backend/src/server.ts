// Em src/server.ts
import express from 'express';
import { config } from './config';
import productRoutes from './api/products.routes';
import orderRoutes from './api/orders.routes';

const app = express();
app.use(express.json());

app.use('/api/products', productRoutes);
app.use('/api/orders', orderRoutes);

app.get('/', (req, res) => {
  return res.json({ message: 'E-commerce API is running!' });
});

app.listen(config.port, () => {
  console.log(`Server running on port ${config.port}`);
});