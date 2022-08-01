//
//  TestingViewController.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 7/28/22.
//

import UIKit
import Charts

class TestingViewController: UIViewController, ChartViewDelegate {

    @IBOutlet weak var velocityView: LineChartView!
    @IBOutlet weak var powerView: LineChartView!
    let load: Int = 225
    let targetVelocity: Int = 110
    var yValuesVelocity: [ChartDataEntry] = []
    var yValuesPower: [ChartDataEntry] = []
    
    let repTime1: [Double] = [1659014947.6699228, 1659014947.718472, 1659014947.7637029, 1659014947.809602, 1659014947.855194, 1659014947.899193, 1659014947.946262, 1659014947.9928532, 1659014948.042784, 1659014948.08714, 1659014948.134373, 1659014948.180324, 1659014948.230173, 1659014948.275193, 1659014948.3204079, 1659014948.3694139, 1659014948.416548, 1659014948.463632, 1659014948.5127702, 1659014948.5596108, 1659014948.606453, 1659014948.6537309, 1659014948.699545, 1659014948.7449632, 1659014948.790474, 1659014948.837529, 1659014948.8874788, 1659014948.9338288, 1659014948.985299, 1659014949.0367799, 1659014949.086666, 1659014949.133727, 1659014949.1805549, 1659014949.228308, 1659014949.2742019, 1659014949.320837, 1659014949.3667278, 1659014949.413362, 1659014949.460053, 1659014949.511327, 1659014949.558461, 1659014949.605258, 1659014949.660943, 1659014949.710298, 1659014949.758074, 1659014949.805752, 1659014949.853253, 1659014949.899842, 1659014949.946301, 1659014949.991847, 1659014950.0381222, 1659014950.085474, 1659014950.13796, 1659014950.193523, 1659014950.249248, 1659014950.304667, 1659014950.3596349, 1659014950.4148068, 1659014950.469606, 1659014950.524823]
    let repVelo1: [Double] = [0.0027438944556424905, 0.016256261116948632, 0.018133143993369367, -0.017876128301696242, 0.004822804523739786, 0.013184666103499472, 0.011730492253982008, 0.021018240843315217, 0.03030598943264843, 0.01764221078016259, 0.004978432127676752, -0.0016989184854344452, 0.061706979389081026, 0.059224160324725855, 0.05674134126037068, 0.047537164557720536, 0.038332987855070395, -0.16644663683594318, -0.3750764402117001, -0.45107322163455454, -0.5270700030574089, -1.348097335566453, -1.8207649806002386, -2.2934326256340243, -1.7434074863075746, -1.7851353211221834, -1.8268631559367925, -1.7759790345298199, -1.446083781636384, -1.0134199367004337, -0.5817558625188649, -0.07369284372520912, 0.43762251315415845, 0.9909331244462309, 1.5442437357383034, 1.3568354066019115, 1.2229115054555821, 1.3249568142650272, 1.4270021230744723, 1.7650166418396922, 1.5041158424904615, 1.2432150431412308, 1.3316703101249905, 1.0791114242012274, 0.8265525382774643, 0.16252486595681348, 0.09381006440071125, -0.06256733577129413, -0.07674569175557537, -0.0735021313779576, 0.008016722594056867, -0.016176577634141192, -0.02452457254504926, -0.04732326484716376, 0.0007053329384193089, -0.055458311729317394, -0.02527847420400806, 0.011374807121617902, 0, 0]
    
    let repTime2: [Double] = [1659014953.107835, 1659014953.16159, 1659014953.2170548, 1659014953.269977, 1659014953.3229918, 1659014953.375382, 1659014953.429762, 1659014953.483666, 1659014953.5363889, 1659014953.590506, 1659014953.643527, 1659014953.697607, 1659014953.75054, 1659014953.8031359, 1659014953.856217, 1659014953.9068708, 1659014953.9609509, 1659014954.014608, 1659014954.0683389, 1659014954.121402, 1659014954.1748009, 1659014954.228537, 1659014954.282565, 1659014954.335686, 1659014954.388914, 1659014954.4439979, 1659014954.498413, 1659014954.55135, 1659014954.604363, 1659014954.657944, 1659014954.711539, 1659014954.764431, 1659014954.818894, 1659014954.872042, 1659014954.9246612, 1659014954.978033, 1659014955.0307221, 1659014955.083883, 1659014955.137127, 1659014955.18877, 1659014955.2436008, 1659014955.297298, 1659014955.352181, 1659014955.4075751, 1659014955.461277, 1659014955.515857, 1659014955.570787, 1659014955.624603, 1659014955.675189, 1659014955.727632, 1659014955.781993, 1659014955.834587, 1659014955.886966, 1659014955.93897, 1659014955.98879, 1659014956.040029, 1659014956.0920439, 1659014956.144558, 1659014956.198412, 1659014956.250639]
    let repVelo2: [Double] = [0.001812881296746239, 0.010191357406503801, -0.04244006891108409, 0.041808857343097354, -0.03277002490712046, 0.0065270978831979565, 0.0133885472370375, 0.011539095623126161, 0.003158232463321726, -0.0035997438588406027, -0.009202312568692176, 0.01789810113973847, -0.003878446717266118, -0.00573155904364676, -0.008247812480102016, -0.009706986707568952, -0.01116616093503589, 0.029007918752484114, -0.02421269546219463, 0.033236725890973054, 0.0005510522362266876, -0.013898785519687212, 0.00950409556973769, -0.0017109003491547618, 0.05353025932227882, 0.0012287935648660207, -0.1900183361177768, -0.6181025902336935, -0.9509268369432895, -1.2837510836528856, -1.4993384926477678, -1.71492590164265, -1.761836431472688, -1.808746961302726, -2.090240930315533, -1.9434880398645673, -1.7967351494136015, -1.0412162259832372, -0.4224507870995723, 0.701689677211334, 0.8919116916408583, 1.0821337060703826, 2.5685584577089244, 1.0505004382730128, 1.2137130602657837, 1.376925682258555, 1.714439486748576, 1.7011937556391312, 1.3449163896304621, 0.9886390236217928, 0.6230411288234279, 0.2574432340250631, -0.015176306210851415, -0.12018566737131263, -0.1116411326529712, -0.039557351430060055, -0.02628927247798259, 0.01628978291978651, 0, 0]
    
    let repTime3: [Double] = [1659014959.08117, 1659014959.135518, 1659014959.190799, 1659014959.245359, 1659014959.2984529, 1659014959.351708, 1659014959.4057221, 1659014959.459035, 1659014959.5086951, 1659014959.562006, 1659014959.615242, 1659014959.6689858, 1659014959.722758, 1659014959.776013, 1659014959.829527, 1659014959.88427, 1659014959.937069, 1659014959.9896731, 1659014960.043541, 1659014960.096209, 1659014960.150367, 1659014960.205069, 1659014960.258967, 1659014960.312882, 1659014960.365996, 1659014960.422025, 1659014960.475878, 1659014960.530532, 1659014960.5861669, 1659014960.6406589, 1659014960.694968, 1659014960.750849, 1659014960.8058271, 1659014960.8597279, 1659014960.913321, 1659014960.9685822, 1659014961.022297, 1659014961.078568, 1659014961.133208, 1659014961.187895, 1659014961.242634, 1659014961.297248, 1659014961.351606, 1659014961.406672, 1659014961.462068, 1659014961.5162559, 1659014961.571601, 1659014961.627739, 1659014961.6821342, 1659014961.738406, 1659014961.79467, 1659014961.848042, 1659014961.893591, 1659014961.938816, 1659014961.982647, 1659014962.028424, 1659014962.073772, 1659014962.121976, 1659014962.168126, 1659014962.21292]
    let repVelo3: [Double] = [-0.002504505172578137, 0.006175826529330337, 0.010132130290284593, -0.011888146040065085, 0.030958754142518332, -0.01739080849996314, -0.0064842274071499175, 0.004563449346529322, 0.015495343666023365, 0.026427237985517407, -0.017832491154227432, 0.01070812907671011, -0.012311102612872894, 0.002464597326317355, 0.03882334633067381, 0.04084024288321228, -0.12458142831208083, -0.5330125939685998, -0.9152637834601729, -1.2975149729517461, -1.4636070215606922, -1.6296990701696383, -2.121483770271537, -1.7172276749405473, -1.6400621746065642, -1.5628966742725812, -1.8128217689356048, -1.737332416992783, 0.003665329825886481, -1.0855648588626945, -0.36296798776591893, 0.23335838985380375, 0.302968706760648, 1.932836425313421, 2.263402832099591, 2.593969238885761, 1.8021806532015616, 1.0103920675173623, 1.1985152421804863, 1.1415993778293594, 1.0846835134782324, 0.9949564081391999, 0.9043496229058547, 0.8137428376725097, 0.45548177811620477, 0.07315874328456448, -0.09121625804631069, -0.12087038472934818, 0.005107925811245872, 0.014506222911204134, 0.03955280837936945, -0.008867960453504674, 0.015477418079243901, -0.03214514393965235, -0.027758666957490175, -0.027191029057269243, -0.026623391157048315, 0.021217874294717137, 0, 0]
    
    
    var velocityCurve: [Double] = [0.002743894,0.016256261,0.018133144,-0.017876128,0.004822805,0.013184666,0.001612066,0.010276318,0.030305989,0.001210771,0.004978432,-0.001698918,0.061706979,0.046679137,0.056741341,0.009293333,0.038332988,-0.166446637,-0.37507644,-0.367606493,-0.527070003,-1.348097336,-1.018699165,-2.293432626,-0.801811839,-1.193382347,-1.826863156,-1.775979035,-1.446083782,-1.013419937,-0.581755863,-0.073692844,0.437622513,0.394084594,1.544243736,1.356835407,0.77536012,1.088987604,0.612571165,1.765016642,1.154759776,0.971057501,1.33167031,0.472112106,0.826552538,0.162524866,0.093810064,-0.062567336,-0.076745692,-0.073502131,0.008016723,-0.016176578,-0.024524573,-0.047323265,0.000705333,-0.055458312,-0.025278474,0.011374807,0.030595542,0.003510375]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let smooth1 = smoothCurveOut(velocityCurve: velocityCurve)
        let smooth2 = smoothCurveOut(velocityCurve: repVelo2)
        let smooth3 = smoothCurveOut(velocityCurve: repVelo3)
        
        let completeRep1 = CompletedRep(timeArray: repTime1, velocityArray: smooth1.0, load: load, targetVelocity: targetVelocity)
        let completeRep2 = CompletedRep(timeArray: repTime2, velocityArray: smooth2.0, load: load, targetVelocity: targetVelocity)
        let completeRep3 = CompletedRep(timeArray: repTime3, velocityArray: smooth3.0, load: load, targetVelocity: targetVelocity)
        
        for index in completeRep1.beginRepIndex ... completeRep1.endRepIndex {
            let entryPoint = ChartDataEntry(x: completeRep1.normalizedTimeArray[index], y: smooth1.0[index])
            yValuesVelocity.append(entryPoint)
        }
        
        for index in 0 ..< completeRep1.accelerationTimeArray.count {
            let entryPoint = ChartDataEntry(x: completeRep1.accelerationTimeArray[index], y: Double(completeRep1.powerArray[index]))
            yValuesPower.append(entryPoint)
        }
        
        setData()
        formatVelocityGraph()

    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("Selected X: \(entry.x)")
    }
    
    
    func setData() {
        let set1 = LineChartDataSet(entries: yValuesVelocity, label: "Velocity (m/s)")
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 2
        set1.setColor(UIColor(named: "Color1-2") ?? .systemRed)
        set1.fill = Fill(CGColor: (UIColor(named: "Color1-2") ?? .systemRed).cgColor)
        set1.fillAlpha = 0.5
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = false
        
        let dataVelocity = LineChartData(dataSet: set1)
        dataVelocity.setDrawValues(false)
        
        velocityView.data = dataVelocity
        
        let set2 = LineChartDataSet(entries: yValuesPower, label: "Power (Watts)")
        set2.mode = .cubicBezier
        set2.drawCirclesEnabled = false
        set2.lineWidth = 2
        set2.setColor(UIColor(named: "Color5") ?? .systemRed)
        set2.fill = Fill(CGColor: (UIColor(named: "Color5") ?? .systemRed).cgColor)
        set2.fillAlpha = 0.5
        set2.drawFilledEnabled = true
        set2.drawHorizontalHighlightIndicatorEnabled = false
        set2.drawVerticalHighlightIndicatorEnabled = false
        
        let dataPower = LineChartData(dataSet: set2)
        dataPower.setDrawValues(false)
        powerView.data = dataPower
    }
    
    func formatVelocityGraph() {
        velocityView.rightAxis.enabled = false
        let yAxis = velocityView.leftAxis
        
        yAxis.labelFont = .boldSystemFont(ofSize: 10)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = UIColor(named: "Color1-2") ?? .systemRed
        yAxis.axisLineColor = UIColor(named: "Color1-2") ?? .systemRed
        yAxis.labelPosition = .outsideChart
        
        velocityView.xAxis.labelPosition = .bottom
        velocityView.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        velocityView.xAxis.setLabelCount(6, force: false)
        velocityView.xAxis.labelTextColor = UIColor(named: "Color1-2") ?? .systemRed
        velocityView.xAxis.axisLineColor = UIColor(named: "Color1-2") ?? .systemRed
        
        velocityView.backgroundColor = UIColor(named: "Color4-2") ?? .systemRed
        velocityView.drawGridBackgroundEnabled = false
        velocityView.legend.textColor = UIColor(named: "Color4-2") ?? .systemRed
        velocityView.legend.horizontalAlignment = .center
        velocityView.legend.verticalAlignment = .top
        velocityView.animate(xAxisDuration: 3.0)
        
        powerView.rightAxis.enabled = false
        let yAxisPower = powerView.leftAxis
        
        yAxisPower.labelFont = .boldSystemFont(ofSize: 10)
        yAxisPower.setLabelCount(6, force: false)
        yAxisPower.labelTextColor = UIColor(named: "Color5") ?? .systemRed
        yAxisPower.axisLineColor = UIColor(named: "Color5") ?? .systemRed
        yAxisPower.labelPosition = .outsideChart
        
        powerView.xAxis.labelPosition = .bottom
        powerView.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        powerView.xAxis.setLabelCount(6, force: false)
        powerView.xAxis.labelTextColor = UIColor(named: "Color5") ?? .systemRed
        powerView.xAxis.axisLineColor = UIColor(named: "Color5") ?? .systemRed
        powerView.xAxis.axisMinimum = velocityView.chartXMin
        powerView.xAxis.axisMaximum = velocityView.chartXMax
        
        powerView.backgroundColor = UIColor(named: "Color4-2") ?? .systemRed
        powerView.drawGridBackgroundEnabled = false
        powerView.legend.textColor = UIColor(named: "Color5") ?? .systemRed
        powerView.legend.horizontalAlignment = .center
        powerView.legend.verticalAlignment = .top
        powerView.animate(xAxisDuration: 3.0)
        
    }
    
    func smoothCurveOut(velocityCurve: [Double]) -> ([Double], Bool) {
        var smoothCurve = false
        var editableVelocityCurve = velocityCurve
        
        for velocityIndex in 0 ..< editableVelocityCurve.count {
            if abs(editableVelocityCurve[velocityIndex]) < 0.13 {
                editableVelocityCurve[velocityIndex] = 0.0
            }
        }
        
        var smoothAttempts = 0
        while smoothCurve == false {
            var k = 1
            var filterCounter = 0
            while k < velocityCurve.count - 1 {
                var currentVelocity = editableVelocityCurve[k]
                if currentVelocity < 0 {
                    if currentVelocity > editableVelocityCurve[k-1] && currentVelocity > editableVelocityCurve[k+1] {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    }
                } else if currentVelocity > 0 {
                    if currentVelocity < editableVelocityCurve[k-1] && currentVelocity < editableVelocityCurve[k+1] {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    }
                } else {
                    if editableVelocityCurve[k-1] > 0 && editableVelocityCurve[k+1] > 0 {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    } else if editableVelocityCurve[k-1] < 0 && editableVelocityCurve[k+1] < 0 {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    }
                }
                
                editableVelocityCurve[k] = currentVelocity
                k += 1
            }
            print("Filter Count: \(filterCounter)")
            smoothAttempts += 1
            
            if filterCounter == 0 {
                smoothCurve = true
            } else if smoothAttempts > 20 {
                break
            }
        }
        return (editableVelocityCurve, smoothCurve)
    }
}
