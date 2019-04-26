//
//  ViewController.swift
//  LotsOfDataGraph
//
//  Created by Ben Lambert on 9/5/17.
//  Copyright © 2017 collectiveidea. All rights reserved.
//

import UIKit
import CollectionGraph

class ViewController: UIViewController {

    @IBOutlet weak var graphCollectionView: GraphCollectionView!
    
    let ppmRepo = PPMRepo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphCollectionView.contentInset = UIEdgeInsets(top: 10, left: 30, bottom: 0, right: 30)
        graphCollectionView.usesWholeNumbersOnYAxis = true
        graphCollectionView.isLineGraph = true
        graphCollectionView.hasXAxisLabels = true
        graphCollectionView.hasYAxisLabels = true
        graphCollectionView.hasHorizontalGraphLines = true
        graphCollectionView.isBarGraph = true
        
        fetchData()
    }
    
    func fetchData() {
        ppmRepo.getPPM { (finished) in
            self.graphCollectionView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.ppmRepo.insertData()

            self.graphCollectionView.insertItems(at: [IndexPath(row: 5, section: 0)])
        }
    }
    
}

extension ViewController: CollectionGraphDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ppmRepo.data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layer.cornerRadius = cell.frame.width / 2
        return cell
    }
    
    func collectionView(_ collectionView: GraphCollectionView, valueFor indexPath: IndexPath) -> (xValue: CGFloat, yValue: CGFloat) {
        return ppmRepo.valueFor(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case .graphLayoutElementKindLine:
            let line = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: .graphLayoutElementKindLine,
                                                                       for: indexPath)
            return line
        case .graphLayoutElementKindXAxisView:
            let xLabel = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: .graphLayoutElementKindXAxisView,
                                                                         for: indexPath) as! LabelReusableView
            
            xLabel.label.text = textForXLabelAt(indexPath: indexPath, fromValue: xLabel.value)
            
            xLabel.valueChanged = { [unowned self] value, indexPath in
                xLabel.label.text = self.textForXLabelAt(indexPath: indexPath, fromValue: value)
            }
            
            return xLabel
            
        case .graphLayoutElementKindYAxisView:
            let yLabel = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: .graphLayoutElementKindYAxisView,
                                                                         for: indexPath) as! LabelReusableView
            let color = collectionView.backgroundColor?.withAlphaComponent(0.8)
            yLabel.backgroundColor = color
            
            yLabel.label.text = String(format: "%.0f", yLabel.value)
            
            yLabel.valueChanged = { value, indexPath in
                yLabel.label.text = String(format: "%.0f", value)
            }
            
            return yLabel
            
        case .graphLayoutElementKindBarGraph:
            return collectionView.dequeueReusableSupplementaryView(ofKind: .graphLayoutElementKindBarGraph, withReuseIdentifier: .graphLayoutElementKindBarGraph, for: indexPath)
            
        default:
            let horizontalView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: .graphLayoutElementKindHorrizontalDividersView,
                                                                         for: indexPath) as! HorizontalDividerLineReusableView
            horizontalView.line.lineDashPattern = [10, 5]
            return horizontalView
        }
    }
    
    func textForXLabelAt(indexPath: IndexPath, fromValue value: CGFloat) -> String {
        if indexPath.item % 2 != 0 {
            return "•"
        } else {
            let labelText = self.convertFloatValueToDate(xLabelValue: value)
            return labelText
        }
    }
    
    func convertFloatValueToDate(xLabelValue value: CGFloat) -> String {
        let date = Date(timeIntervalSince1970: Double(value))
        let customFormat = DateFormatter.dateFormat(fromTemplate: "MMM d hh:mm", options: 0, locale: Locale(identifier: "us"))!
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = customFormat
        
        return formatter.string(from: date)
    }
    
}

extension ViewController: CollectionGraphDelegateLayout {
    
    func graphCollectionView(_ graphCollectionView: GraphCollectionView, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 10, height: 10)
    }
    
    func minAndMaxYValuesIn(_ graphCollectionView: GraphCollectionView) -> (min: CGFloat, max: CGFloat) {
        let values = ppmRepo.getMinAndMaxCo2Values()
        
        return values
    }
    
    func numberOfYStepsIn(_ graphCollectionView: GraphCollectionView) -> Int {
        return ppmRepo.data.isEmpty ? 0 : 6
    }
    
    func minAndMaxXValuesIn(_ graphCollectionView: GraphCollectionView) -> (min: CGFloat, max: CGFloat) {
        let values = ppmRepo.getMinAndMaxDateFloatValues()
        
        return values
    }
    
    func numberOfXStepsIn(_ graphCollectionView: GraphCollectionView) -> Int {
        return ppmRepo.data.isEmpty ? 0 : 50
    }
    
    func distanceBetweenXStepsIn(_ graphCollectionView: GraphCollectionView) -> CGFloat {
        return 150
    }
    
}
