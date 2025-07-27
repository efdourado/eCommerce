import 'dotenv/config';

export const config = {
  port: process.env.PORT || 3333,
  db: {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  },
  ssl: true,
};