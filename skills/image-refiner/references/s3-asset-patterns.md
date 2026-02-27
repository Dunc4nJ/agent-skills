# S3 Product Image Asset Patterns

## Base Pattern

```
s3://bananabank-media-lake/{brand_lower}/catalog/products/{product_line}/{product_slug}/{image_type}.png
```

## Image Types Available

| File | Description | Priority |
|---|---|---|
| hero.png | Front-facing hero shot | Always download |
| angle-1.png | Secondary angle | Download if available |
| angle-2.png through angle-6.png | Additional angles | Use on retry attempts |

## Brand-Specific Patterns

### TableClay
```
s3://bananabank-media-lake/tableclay/catalog/products/{line}/{slug}/hero.png
```
Product lines and slugs from: `product-catalog.md` in vault.

### Other Brands
```
s3://bananabank-media-lake/{brand_name_lowercase}/catalog/products/{line}/{slug}/hero.png
```

## AWS Access

```bash
# Profile: polytrader (configured in ~/.aws/credentials)
# Region: eu-west-1

# Download hero
aws s3 cp s3://bananabank-media-lake/{brand}/catalog/products/{line}/{slug}/hero.png /tmp/product-ref-hero.png --profile polytrader --region eu-west-1

# Download angle-1
aws s3 cp s3://bananabank-media-lake/{brand}/catalog/products/{line}/{slug}/angle-1.png /tmp/product-ref-angle1.png --profile polytrader --region eu-west-1

# List available images for a product
aws s3 ls s3://bananabank-media-lake/{brand}/catalog/products/{line}/{slug}/ --profile polytrader --region eu-west-1
```

## Fallback

If S3 download fails (bucket doesn't exist, product not cataloged, permissions):
1. Log the error
2. Fall back to text-only refinement
3. Use detailed product description from `product-catalog.md`
