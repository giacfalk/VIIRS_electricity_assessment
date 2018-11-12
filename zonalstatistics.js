var collection = ee.ImageCollection('NOAA/VIIRS/DNB/MONTHLY_V1/VCMSLCFG').filterDate('2014-01-01', '2017-01-01').select('avg_rad');
    print('collection', collection);
    print('Number of images in collection:', collection.size());

var replacement = ee.Image(0);
    
var conditional = function(image) {
  return image.where(image.lt(2), replacement);
};

var output = collection.map(conditional);

var replacementd = ee.Image(0);
    
var conditionald = function(imaged) {
  return imaged.where(imaged.gt(300), replacementd);
};

var outputd = output.map(conditionald);    

var stackCollection = function(collection) {
  // Create an initial image.
  var first = ee.Image(collection.first()).select([]);

  // Write a function that appends a band to an image.
  var appendBands = function(image, previous) {
    return ee.Image(previous).addBands(image);
  };
  return ee.Image(collection.iterate(appendBands, first));
};

var stacked = stackCollection(outputd);
print('stacked image', stacked);

Map.addLayer(stacked)

//reproject both shapefile and rasterstack


// Define a feature collection (grid features).
var Countries = ee.FeatureCollection('users/username/gadm')

Map.addLayer(Countries);

// Add reducer output to the Features in the collection.
var lightsum = stacked.reduceRegions({
  collection: Countries,
  reducer: ee.Reducer.sum()
});

Export.table.toDrive({
  collection: lightsum,
  description:'biglightsum',
  fileFormat: 'SHP'
});
