//
//  ViewController.swift
//  Lab8_nihalsuneer
//
//  Created by user235383 on 11/17/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {


    @IBOutlet weak var locationLabel: UILabel!
    
    
    @IBOutlet weak var climateLabel: UILabel!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var tempLabel: UILabel!
    
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    
    @IBOutlet weak var windLabel: UILabel!

        private var locationManager = CLLocationManager()
        private var weather: WeatherModel?

        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            setupLocationManager()
        }
        
        private func setupUI() {            //user interface setup
            view.backgroundColor = .white
            
            let stackView = UIStackView(arrangedSubviews: [locationLabel, climateLabel, imageView, tempLabel, humidityLabel, windLabel])
            stackView.axis = .vertical
            stackView.spacing = 10
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        
        private func setupLocationManager() {   //location manager
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    
    
        
        // Location Manager Delegate
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.first?.coordinate else { return }
            
            WeatherService().getWeather(for: location) { result in
                switch result {
                case .success(let weatherResponse):
                    DispatchQueue.main.async {
                        self.weather = WeatherModel(weatherResponse: weatherResponse)
                        self.updateUI()
                    }
                case .failure(let error):
                    print("Error fetching weather: \(error)")
                }
            }
        }
        
        private func updateUI() {       //update content
            guard let weather = weather else { return }
            
            locationLabel.text = "City: \(weather.city)"
            climateLabel.text = "Description: \(weather.weatherDescription)"
            switch weather.weatherIcon {
                    case "01d":
                        imageView.image = UIImage(systemName: "sun.max.fill")
                    case "01n":
                        imageView.image = UIImage(systemName: "moon.fill")
                    case "02d", "02n":
                        imageView.image = UIImage(systemName: "cloud.sun.fill")
                    case "03d", "03n":
                        imageView.image = UIImage(systemName: "cloud.fill")
                    case "04d", "04n":
                        imageView.image = UIImage(systemName: "cloud")
                    case "09d", "09n":
                        imageView.image = UIImage(systemName: "cloud.drizzle.fill")
                    case "10d", "10n":
                        imageView.image = UIImage(systemName: "cloud.rain.fill")
                    case "11d", "11n":
                        imageView.image = UIImage(systemName: "cloud.bolt.fill")
                    case "13d", "13n":
                        imageView.image = UIImage(systemName: "cloud.snow.fill")
                    case "50d", "50n":
                        imageView.image = UIImage(systemName: "cloud.fog.fill")
                        
                    default:
                        imageView.image = UIImage(systemName: "questionmark.diamond.fill")
                    }
            tempLabel.text = "Temperature: \(weather.temperature)°C"
            humidityLabel.text = "Humidity: \(weather.humidity)%"
            windLabel.text = "Wind Speed: \(weather.windSpeed) m/s"
        }
        
        
        private class WeatherService {  //system weather service
            private let apiKey = "0825a49387bc347d2e02cae3f94aee87"
            private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
            
            func getWeather(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
                let urlString = "\(baseURL)?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=metric&appid=\(apiKey)"
                guard let url = URL(string: urlString) else {
                    completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        completion(.failure(error!))
                        return
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                        completion(.success(weatherResponse))
                    } catch {
                        completion(.failure(error))
                    }
                }.resume()
            }
        }
        
    
        private struct WeatherResponse: Codable {   //weather formats
            let main: Main
            let weather: [Weather]
            let wind: Wind
        }
        
        private struct Main: Codable {
            let temp: Double
            let humidity: Int
        }
        
        private struct Weather: Codable {
            let description: String
            let icon: String
        }
        
        private struct Wind: Codable {
            let speed: Double
        }
        
        private struct WeatherModel {
            let city: String
            let weatherDescription: String
            let weatherIcon: String
            let temperature: Double
            let humidity: Int
            let windSpeed: Double
            
            init(weatherResponse: WeatherResponse) {
                self.city = "Waterloo"
                self.weatherDescription = weatherResponse.weather[0].description
                self.weatherIcon = weatherResponse.weather[0].icon
                self.temperature = weatherResponse.main.temp
                self.humidity = weatherResponse.main.humidity
                self.windSpeed = weatherResponse.wind.speed
            }
        }
    }


