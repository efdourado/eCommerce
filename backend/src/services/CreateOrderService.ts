import db from '../database';

interface IProductRequest {
  product_id: number;
  qty: number;
}

interface IRequest {
  userId: number;
  addressId: number;
  paymentMethodId: number;
  products: IProductRequest[];
}

class CreateOrderService {
  public async execute({ userId, addressId, paymentMethodId, products }: IRequest): Promise<void> {
    const productsJson = JSON.stringify(products);

    await db.query('CALL create_new_order($1::INT, $2::INT, $3::INT, $4::JSON)', [
      userId,
      paymentMethodId,
      addressId,
      productsJson,
]); } }

export default CreateOrderService;