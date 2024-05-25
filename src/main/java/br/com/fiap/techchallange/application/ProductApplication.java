package br.com.fiap.techchallange.application;

import br.com.fiap.techchallange.application.ports.out.repository.IProductRepository;
import br.com.fiap.techchallange.domain.entity.Product;

import java.util.List;

public class ProductApplication {

    final IProductRepository productRepository;

    public ProductApplication(IProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public List<Product> getProducts() {
        List<Product> productList = this.productRepository.getProducts();
        return productList;
    }

    public Product getProductBySku(String sku) {
        return this.productRepository.getProductBySku(sku);
    }

    public void deleteProduct(String sku) {
        productRepository.deleteProduct(sku);
    }

    public void createProduct(Product product) {
        productRepository.createProduct(product);
    }

    public void updateProduct(String sku, Product product) {
        productRepository.updateProduct(sku, product);
    }
}
