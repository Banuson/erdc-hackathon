import { LightningElement, wire } from 'lwc';
import leaflet from '@salesforce/resourceUrl/leaflet';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import redPin from '@salesforce/resourceUrl/redPin';
import greenPin from '@salesforce/resourceUrl/greenPin';
import orangePin from '@salesforce/resourceUrl/orangePin';
import getStationInfo from '@salesforce/apex/ERDC_MapController.getStationInfo';
import getLineInfo from '@salesforce/apex/ERDC_MapController.getLineInfo';
export default class ERDCMap extends LightningElement {

  stations;
  lines;
  error;

  renderedCallback() {
    console.log('render callback');

    Promise.all([
      getStationInfo().then(result => { this.stations = result }),
      getLineInfo().then(result => { this.lines = result }),
      loadScript(this, leaflet + '/leaflet.js'),
      loadStyle(this, leaflet + '/leaflet.css')])
      .then(() => {
        this.initLeaflet();
        console.log('promise return sucessfully');
      })
      .catch(error => { console.log(error); });
  }
  initLeaflet() {
    console.log('init loaded');
    const mapDiv = this.template.querySelector(".map-root");

    var mymap = L.map(mapDiv).setView([44.43636802767406, 26.10234357308725], 13);
    var Stamen_TonerLite = L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/toner-lite/{z}/{x}/{y}{r}.{ext}', {
      attribution: 'Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      subdomains: 'abcd',
      minZoom: 0,
      maxZoom: 20,
      ext: 'png'
    }).addTo(mymap);

    //48x66
    var iconPins = {
      "green": new L.Icon({
        iconUrl: greenPin,
        iconSize: [24, 33],
        iconAnchor: [12, 33], // point of the icon which will correspond to marker's location
        popupAnchor: [0, -33]
      }),
      "orange": new L.Icon({
        iconUrl: orangePin,
        iconSize: [23, 33],
        iconAnchor: [12, 33], // point of the icon which will correspond to marker's location
        popupAnchor: [0, -33]
      })
      ,
      "red": new L.Icon({
        iconUrl: redPin,
        iconSize: [23, 33],
        iconAnchor: [12, 33], // point of the icon which will correspond to marker's location
        popupAnchor: [0, -33]
      })
    };

    for (const stationData of this.stations) {
      var urlString = window.location.href;
      var baseURL = urlString.substring(0, urlString.indexOf("/n"));
      var navToRecURL = baseURL + '/r/ERDC_Station__c/' + stationData.Id + '/view';

      var marker = new L.Marker([stationData.ERDC_Location__Latitude__s, stationData.ERDC_Location__Longitude__s], { icon: stationData.ERDC_Trip_Count__c > 10 ? iconPins['red'] : stationData.ERDC_Trip_Count__c > 5 ? iconPins['orange'] : iconPins['green'] }).addTo(mymap);
      marker.bindPopup(
        '<strong>Name :' + stationData.Name + '<br>Lat: ' + stationData.ERDC_Location__Latitude__s + ' Long:' + stationData.ERDC_Location__Longitude__s + '<br>' +
        '<a  target="_blank" href="' + navToRecURL + '">' + stationData.Name + '</a></strong>');
    }

    for (const line of this.lines) {
      
      var urlString = window.location.href;
      var baseURL = urlString.substring(0, urlString.indexOf("/n"));
      var navToRecURL = baseURL + '/r/ERDC_Line__c/' + line.Id + '/view';

      var latlngs = eval(line.ERDC_Coordinates__c);
      latlngs.forEach(coords => coords.reverse());
      console.log(JSON.stringify(latlngs));
      var polyline = L.polyline(latlngs, { color: line.ERDC_Map_Color__c, weight: 7, lineJoin: 'round' }).addTo(mymap);
      polyline.bindPopup('<strong>' + '<a  target="_blank" href="' + navToRecURL + '">' + line.Name + '</a></strong>');
    }
  }


}