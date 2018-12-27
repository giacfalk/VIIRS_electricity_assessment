var collection12 = ee.ImageCollection('NOAA/VIIRS/DNB/MONTHLY_V1/VCMCFG').filterDate('2012-01-01', '2013-01-01').select('avg_rad');
var collection13 = ee.ImageCollection('NOAA/VIIRS/DNB/MONTHLY_V1/VCMCFG').filterDate('2013-01-01', '2014-01-01').select('avg_rad');
var collection14 = ee.ImageCollection('NOAA/VIIRS/DNB/MONTHLY_V1/VCMCFG').filterDate('2014-01-01', '2015-01-01').select('avg_rad');
var collection15 = ee.ImageCollection('NOAA/VIIRS/DNB/MONTHLY_V1/VCMCFG').filterDate('2015-01-01', '2016-01-01').select('avg_rad');
var collection16 = ee.ImageCollection('NOAA/VIIRS/DNB/MONTHLY_V1/VCMCFG').filterDate('2016-01-01', '2017-01-01').select('avg_rad');

var replacement = ee.Image(0);
    
var conditional = function(image) {
  return image.where(image.lt(0.25), replacement);
};

var collection12 = collection12.map(conditional);
var collection13 = collection13.map(conditional);
var collection14 = collection14.map(conditional);
var collection15 = collection15.map(conditional);
var collection16 = collection16.map(conditional);

var replacementd = ee.Image(0);
    
var conditionald = function(imaged) {
  return imaged.where(imaged.gt(300), replacementd);
};

var collection12 = collection12.map(conditionald);
var collection13 = collection13.map(conditionald);
var collection14 = collection14.map(conditionald);
var collection15 = collection15.map(conditionald);
var collection16 = collection16.map(conditionald);

var collection12 = collection14.median()
var collection13 = collection15.median()
var collection14 = collection14.median()
var collection15 = collection15.median()
var collection16 = collection16.median()

Map.addLayer(collection12)
Map.addLayer(collection13)
Map.addLayer(collection14)
Map.addLayer(collection15)
Map.addLayer(collection16)

var Countries = ee.FeatureCollection('users/giacomofalchetta/gadm')

var collection12 = collection12.reduceRegions({
  collection: Countries,
  reducer: ee.Reducer.sum(),
  scale: 450
});

var collection12 = collection12.select(['.*'],null,false);

Export.table.toDrive({
  collection: collection12,
    folder: 'energies',
  description:'collection12',
  fileFormat: 'CSV'
});

var collection13 = collection13.reduceRegions({
  collection: Countries,
  reducer: ee.Reducer.sum(),
  scale: 450
});

var collection13 = collection13.select(['.*'],null,false);

Export.table.toDrive({
  collection: collection13,
    folder: 'energies',
  description:'collection13',
  fileFormat: 'CSV'
});

var collection14 = collection14.reduceRegions({
  collection: Countries,
  reducer: ee.Reducer.sum(),
  scale: 450
});

var collection14 = collection14.select(['.*'],null,false);

Export.table.toDrive({
  collection: collection14,
    folder: 'energies',
  description:'collection14',
  fileFormat: 'CSV'
});

var collection15 = collection15.reduceRegions({
  collection: Countries,
  reducer: ee.Reducer.sum(),
  scale: 450
});

var collection15 = collection15.select(['.*'],null,false);

Export.table.toDrive({
  collection: collection15,
    folder: 'energies',
  description:'collection15',
  fileFormat: 'CSV'
});

var collection16 = collection16.reduceRegions({
  collection: Countries,
  reducer: ee.Reducer.sum(),
  scale: 450
});


var collection16 = collection16.select(['.*'],null,false);

Export.table.toDrive({
  collection: collection16,
  folder: 'energies',
  description:'collection16',
  fileFormat: 'CSV'
});