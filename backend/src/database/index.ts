import { Pool } from 'pg';
import { config } from '../config';

const pool = new Pool({
  host: config.db.host,
  port: config.db.port,
  user: config.db.user,
  password: config.db.password,
  database: config.db.database,
  ssl: true,
});

pool.on('connect', () => {
  console.log('Cloud Database connected successfully!');
});

export default pool;