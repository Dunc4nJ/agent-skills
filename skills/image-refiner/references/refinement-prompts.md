# Refinement Prompt Templates

## Base Template (All Scenes)

```
Edit this image. Replace the {product_described} with the product shown in the reference image(s). Match the lighting ({lighting_direction}), shadows, perspective, and scale of the original scene. The product should look naturally placed in the environment. Product is at {product_location}, occupying roughly {product_scale} of the frame. {additional_notes}
```

## Scene-Specific Adjustments

### Lifestyle / Indoor
Add: "Maintain the ambient room lighting and any reflections on nearby surfaces. The product should cast a soft shadow consistent with the existing light source."

### Flat Lay / Top-Down
Add: "Keep the top-down perspective consistent. The product should have no perspective distortion and cast a subtle drop shadow matching other objects in the scene."

### Outdoor / Natural Light
Add: "Match the natural sunlight direction and intensity. The product should have environmental reflections consistent with the outdoor setting (sky color, ambient light)."

### Studio / Minimal
Add: "Maintain the clean studio aesthetic. The product should have sharp, controlled lighting matching the existing setup with smooth gradient shadows."

### In-Use / Hands
Add: "The product should look like it's being naturally held or used. Match the hand position and grip. Ensure the product's scale is realistic relative to the hands."

### Mood Board / Collage
Add: "Place the product as a styled element within the composition. Match the color grading and any filters applied to the overall image."

## Text-Only Fallback Template

When S3 reference images are unavailable:

```
Edit this image. Replace the {product_described} with a photorealistic rendering of: {detailed_product_description_from_catalog}. Physical specs: {dimensions}, {colors}, {materials}, {texture}. Match the lighting ({lighting_direction}), shadows, perspective, and scale of the original scene. The product should look naturally placed at {product_location}. {additional_notes}
```

## Multi-Attempt Adjustments

On retry (attempt 2+), incorporate user feedback and try:
- **Different angle reference:** Upload angle-1.png instead of hero.png (or both)
- **Adjusted lighting description:** Be more specific about light temperature, intensity
- **Scale correction:** "Make the product slightly {larger/smaller}"
- **Position nudge:** "Shift the product slightly {direction}"
- **Material emphasis:** "The product surface is {matte/glossy/textured}, ensure proper light interaction"
