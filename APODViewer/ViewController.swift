//
//  ViewController.swift
//  APODViewer
//
//  Created by Ryan Saunders on 2023-01-16.
//

import UIKit


struct NasaJson: Codable {
    let explanation: String?
    let url: String
}

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var urlString = ""
    private var dataTask: URLSessionDataTask? // Storing this one so we can cancel it if another date is selected.
    
    private var nasaJson: NasaJson? {
        didSet {
            guard let nasaJson = nasaJson else { return }
            descriptionLabel.text = nasaJson.explanation
            imageURLString = nasaJson.url
        }
    }
    private var imageURLString : String? { // Is this overbuilt?
        didSet {
            guard let imageURLString = imageURLString, let url = URL(string: imageURLString) else { return }
            let imageDataTask = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
            imageDataTask.resume()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.numberOfLines = 0
    }
    
    @IBAction func fetchJSON(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        urlString = "https://api.nasa.gov/planetary/apod?api_key=eFD5a3bZunHhZA6ZYEWDOItOZgE3uD7dJncUgor1&date=\(formatter.string(from: datePicker.date))"
        guard let url = URL(string: urlString) else { return }
        dataTask?.cancel()
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("2a. \(error)")
            } //Is this the right way? We don't seem to be getting anything yet.
            
            guard let data = data else { return }
            if let decodedData = try? JSONDecoder().decode(NasaJson.self, from: data) {
                DispatchQueue.main.async {
                    self.nasaJson = decodedData
                }
            }
        }
        dataTask?.resume()
    }
    
    func presentError(error: Error) {
        let ac = UIAlertController(title: "Error", message: "An error occurred. \(error)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present(ac, animated: true)
    }
    

}

