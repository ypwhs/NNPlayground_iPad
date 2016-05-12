//
//  ViewController.m
//  NNPlayground
//
//  Created by 杨培文 on 16/4/21.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import "ViewController.h"
#import "TableViewController.h"

using namespace std;

@interface ViewController ()

@end

@implementation ViewController

//**************************** Thread ***************************
- (void)xiancheng:(dispatch_block_t)code{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), code);
}

- (void)ui:(dispatch_block_t)code{
    dispatch_async(dispatch_get_main_queue(), code);
}

//*************************** Network ***************************
int * networkShape = new int[3]{2, 4, 1};
int layers = 3;
double learningRate = 0.01;
double regularizationRate = 0;
auto activation = Tanh;
auto regularization = None;

Network * network = new Network(networkShape, layers, activation, regularization);
NSLock * networkLock = [[NSLock alloc] init];

- (IBAction)addNetworkLayer:(UIStepper *)sender {
    _myswitch.on = false;
    always = false;
    [networkLock lock];
    int * oldNetworkShape = networkShape;
    networkShape =  new int[layers];
    int newLayers = (int)sender.value + 2;
    
    networkShape = new int[newLayers];
    networkShape[0] = 2;
    int i = 1;
    for(; i < layers - 1; i++){
        networkShape[i] = oldNetworkShape[i];
    }
    int repeatValue = oldNetworkShape[layers - 2];
    layers = newLayers;
    for(;i < layers - 1; i++){
        networkShape[i] = repeatValue;
    }
    networkShape[layers - 1] = 1;
    
    delete[] oldNetworkShape;
    [networkLock unlock];
    
    [self reset];
}

//初始化神经网络
- (void)resetNetwork{
    [networkLock lock];
    epoch = 0;
    lastEpoch = 0;
    Network * oldNetwork = network;
    network = new Network(networkShape, layers, activation, None);
    
    //创建input图像
    vector<Node*> &inputLayer = *network->network[0];
    for(int j = 0; j < 100; j++){
        for(int i = 0; i < 100; i++){
            for(int k = 0; k < inputLayer.size(); k++){
                inputLayer[0]->updateBitmapPixel(i, j, (i - 50.0)/50*6);
                inputLayer[1]->updateBitmapPixel(i, j, (j - 50.0)/50*6);
            }
        }
    }
    
    [networkLock unlock];
    
    [self initNodeLayer];
    
    [networkLock lock];
    //计算loss
    //TO DO
    [networkLock unlock];
    [_heatMap setData:trainx1 x2:trainx2 y:trainy size:trainNum];
    
    //保存数据点截图
//    _fpsLabel.text = @"";
//    UIGraphicsBeginImageContextWithOptions(_heatMap.bounds.size, NO, 0);
//    [_heatMap.dataLayer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
    delete oldNetwork;
    [self updateLabel];
}

//**************************** Inputs ***************************
const int DATA_NUM = 500;
double inputs[] = {1, 1};
double * rawx1 = new double[DATA_NUM];
double * rawx2 = new double[DATA_NUM];
double * rawy = new double[DATA_NUM];
double noise = 0;

#define π 3.1415926

double normalRandom(double mean, double variance){
    double v1, v2, s;
    do {
        v1 = 2 * drand() - 1;
        v2 = 2 * drand() - 1;
        s = v1 * v1 + v2 * v2;
    } while (s > 1);
    
    double result = sqrt(-2 * log(s) / s) * v1;
    return mean + variance * result;
}

void dataset_circle(){
    for(int i = 0; i < DATA_NUM; i++){
        double r;
        if(i < DATA_NUM/2)r = drand(0.7, 0.9);
        else r = drand(0, 0.5);
        double dir = drand(0, 2*π);
        rawx1[i] = r*cos(dir);
        rawx2[i] = r*sin(dir);
        double noisex1 = drand(-1, 1) * noise + rawx1[i];
        double noisex2 = drand(-1, 1) * noise + rawx2[i];
        rawy[i] = (noisex1*noisex1 + noisex2*noisex2)<0.25? 1 : -1;
    }
}

void dataset_twoGaussData(){
    for(int i = 0; i < DATA_NUM; i++){
        rawy[i] = i > DATA_NUM/2 ? 1 : -1;
        double variance = 0.14 + noise*0.5;
        rawx1[i] = normalRandom(rawy[i] * 0.4, variance);
        rawx2[i] = normalRandom(rawy[i] * 0.4, variance);
    }
}

void dataset_xor(){
    double padding = 0.05;
    for(int i = 0; i < DATA_NUM; i++){
        rawx1[i] = drand(-0.8, 0.8);
        rawx2[i] = drand(-0.8, 0.8);
        rawx1[i] += rawx1[i]>0 ? padding : -padding;
        rawx2[i] += rawx2[i]>0 ? padding : -padding;
        double noisex1 = drand(-1, 1) * noise + rawx1[i];
        double noisex2 = drand(-1, 1) * noise + rawx2[i];
        rawy[i] = noisex1*noisex2 > 0 ? 1 : -1;
    }
}

void dataset_spiral(){
    double deltaT = 0;
    for (int i = 0; i < DATA_NUM/2; i++) {
        double n = DATA_NUM/2;
        double r = (double)i / n * 0.8;
        double t = 1.75 * i / n * 2 * π + deltaT;
        rawx1[i] = r * sin(t) + drand(-1, 1)/6 * noise;
        rawx2[i] = r * cos(t) + drand(-1, 1)/6 * noise;
        rawy[i] = 1;
    }
    deltaT = π;
    for (int i = 0; i < DATA_NUM/2; i++) {
        double n = DATA_NUM/2;
        double r = (double)i / n * 0.8;
        double t = 1.75 * i / n * 2 * π + deltaT;
        rawx1[i+DATA_NUM/2] = r * sin(t) + drand(-1, 1)/6 * noise;
        rawx2[i+DATA_NUM/2] = r * cos(t) + drand(-1, 1)/6 * noise;
        rawy[i+DATA_NUM/2] = -1;
    }
}

double * trainx1 = new double[DATA_NUM];
double * trainx2 = new double[DATA_NUM];
double * trainy = new double[DATA_NUM];
double * testx1 = new double[DATA_NUM];
double * testx2 = new double[DATA_NUM];
double * testy = new double[DATA_NUM];
double ratioOfTrainingData = 0.5;

int trainNum = 0;
int testNum = 0;

- (void)updateDataset{
    switch (dataset) {
        case Circle: {
            dataset_circle();
            break;
        }
        case Xor: {
            dataset_xor();
            break;
        }
        case TwoGaussian: {
            dataset_twoGaussData();
            break;
        }
        case Spiral: {
            dataset_spiral();
            break;
        }
    }
    
    //Fisher-Yates algorithm
    for(int i = 0; i < DATA_NUM; i++){
        int r = floor(drand(0, DATA_NUM));
        double t1 = rawx1[i];
        double t2 = rawx2[i];
        double t3 = rawy[i];
        rawx1[i] = rawx1[r];
        rawx2[i] = rawx2[r];
        rawy[i] = rawy[r];
        rawx1[r] = t1;
        rawx2[r] = t2;
        rawy[r] = t3;
    }
    
    trainNum = ratioOfTrainingData * DATA_NUM;
    testNum = DATA_NUM - trainNum;
    for(int i = 0; i < trainNum; i++){
        trainx1[i] = rawx1[i];
        trainx2[i] = rawx2[i];
        trainy[i] = rawy[i];
    }
    
    for(int i = 0; i < testNum; i++){
        testx1[i] = rawx1[trainNum + i];
        testx2[i] = rawx2[trainNum + i];
        testy[i] = rawy[trainNum + i];
    }
    
    [self reset];
    [self updateShadows];
}

double lastRatio = 0.5;
- (IBAction)changeratioOfTrainingData:(UISlider *)sender {
    //1~9
    sender.value = roundf(sender.value);
    ratioOfTrainingData = sender.value/10.0;    //10%~90%
    if(ratioOfTrainingData != lastRatio){
        lastRatio = ratioOfTrainingData;
        [self updateDataset];
    }
    [self updateLabel];
}

double lastNoise = 0;
- (IBAction)changeNoise:(UISlider *)sender {
    //0~10
    sender.value = roundf(sender.value);
    
    noise = sender.value / 20.0;    //0~50%
    if(noise != lastNoise){
        lastNoise = noise;
        [self updateDataset];
    }
    [self updateLabel];
}

-(void) reset{
    _myswitch.on = false;
    always = false;
    [self ui:^{
        [_lossView clearData];
    }];
    [self resetNetwork];
}

- (IBAction)speedup:(UISwitch *)sender {
    if(sender.on){
        trainBatch = 120;
    }else{
        trainBatch = 9;
    }
}

int maxfps = 120;

//*************************** Heatmap ***************************

UIImage * image;
- (void) getHeatData{
    [networkLock lock];
    
    //用100*100网络获取每个结点的输出
    for(int j = 0; j < 100; j++){
        for(int i = 0; i < 100; i++){
            inputs[0] = (i - 50.0)/50;
            inputs[1] = (j - 50.0)/50;
            network->forwardProp(inputs, 2, i, j);
        }
    }
    
    [self ui:^{
        //更新大图
        Node * outputNode = (*network->network[layers-1])[0];
        [_heatMap.backgroundLayer setContents:(id)outputNode->getImage().CGImage];
        
        //更新小图
        for(int i = 0; i < layers - 1; i++){
            for(int j = 0; j < networkShape[i]; j++){
                Node * node = (*network->network[i])[j];
                [CATransaction begin];
                [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                if(layers < 5 && i > 0){
                    node->updateVisibility();
                }
                [node->nodeLayer setContents:(id)node->getImage().CGImage];
                [CATransaction commit];
            }
        }
        
        //更新线宽，颜色
        for(int i = 0; i < layers - 1; i++){
            for(int j = 0; j < networkShape[i]; j++){
                Node * node = (*network->network[i])[j];
                for(int k = 0; k < node->outputs.size(); k++){
                    [CATransaction begin];
                    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
                    node->outputs[k]->updateCurve();
                    [CATransaction commit];
                }
            }
        }
        
    }];
    
    [networkLock unlock];
}


//获取大图
UIImage * bigOutputImage;
int bigOutputImageWidth = 512;
unsigned int * outputBitmap = new unsigned int[bigOutputImageWidth*bigOutputImageWidth];

- (void)generateBigOutputImage{
    bigOutputImage = nil;
    double halfWidth = bigOutputImageWidth/2;
    for(int y = 0; y < bigOutputImageWidth; y++){
        for(int x = 0; x < bigOutputImageWidth; x++){
            inputs[0] = (x - halfWidth)/halfWidth;
            inputs[1] = (y - halfWidth)/halfWidth;
            double output = network->forwardProp(inputs, 2);
            outputBitmap[(bigOutputImageWidth-1-y)*bigOutputImageWidth + x] = getColor(-output);
        }
        [self ui:^{
            hud.progress = (double)y/bigOutputImageWidth;
        }];
    }
    CGContextRef bitmapContext = CGBitmapContextCreate(outputBitmap, bigOutputImageWidth, bigOutputImageWidth, 8, 4*bigOutputImageWidth, CGColorSpaceCreateDeviceRGB(), kCGBitmapByteOrder32Big | kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(bitmapContext);
    bigOutputImage = [UIImage imageWithCGImage:imageRef];
    CGContextRelease(bitmapContext);
    CGImageRelease(imageRef);
}

vector<UIStepper *> steppers;

- (void)addNodeNum:(UIStepper *)sender{
    int currentLayer = (int)sender.tag;
    networkShape[currentLayer] = sender.value;
    [self reset];
}

//初始化每个结点的图像层（CALayer）
- (void) initNodeLayer{
    while(steppers.size()){
        [steppers.back() removeFromSuperview];
        steppers.pop_back();
    }
    [networkLock lock];
    
    CGRect frame = _heatMap.frame;
    (*network->network[layers - 1])[0]->initNodeLayer(frame);   //将heatmap的frame设置到网络的输出结点
    
    //计算各个坐标
    CGFloat x = _ratioOfTrainingDataLabel.frame.origin.x + _ratioOfTrainingDataLabel.frame.size.width + 8;
    CGFloat y = 160;
    
    CGFloat width = frame.origin.x - x;
    width /= layers - 1;    //两个结点的x坐标差
    
    CGFloat height = self.view.frame.size.height - y;
    height /= 8;
    
    CGFloat ndoeWidth = height - 5*screenScale;
    ndoeWidth = ndoeWidth > 40 ? 40 : ndoeWidth;
    frame.size = CGSizeMake(ndoeWidth, ndoeWidth);

    for(int i = 0; i < layers - 1; i++){
        for(int j = 0; j < networkShape[i]; j++){
            frame.origin = CGPointMake(x + width*i, y + height*j);
            Node * node = (*network->network[i])[j];
            node->initNodeLayer(frame);
        }
        if(i > 0){
            UIStepper * stepper = [[UIStepper alloc] initWithFrame:CGRectMake(frame.origin.x + ndoeWidth / 2 - 47, y - 40, 0, 0)];
            stepper.tag = i;
            stepper.value = networkShape[i];
            stepper.minimumValue = 1;
            stepper.maximumValue = 8;
            [stepper addTarget:self action:@selector(addNodeNum:) forControlEvents:UIControlEventValueChanged];
            [self.view addSubview:stepper];
            steppers.push_back(stepper);
        }
    }
    
    [networkLock unlock];
    
    [self getHeatData];
    
    [networkLock lock];
    
    //将每个结点的layer，每个连接线的layer都插入到view中
    for(int i = 0; i < layers - 1; i++){
        for(int j = 0; j < networkShape[i]; j++){
            Node * node = (*network->network[i])[j];
            [self.view.layer addSublayer:node->nodeLayer];
            [self.view.layer addSublayer:node->triangleLayer];
            if(layers < 5 && i > 0){
                node->updateVisibility();
            }
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
            [node->nodeLayer setContents:(id)node->getImage().CGImage];
            [self.view.layer insertSublayer:node->shadowLayer atIndex:0];
            
            for(int k = 0; k < node->outputs.size(); k++){
                Link * link = node->outputs[k];
                link->initCurve();
                [self.view.layer insertSublayer:link->curveLayer atIndex:0];
            }
            [CATransaction commit];
        }
    }
    
    [networkLock unlock];
}

//**************************** Train ****************************
bool always = false;
int trainBatch = 9;
int batch = 30;
int epoch = 0;
int lastEpoch = 0;
int speed = 0;
double lastEpochTime = [NSDate date].timeIntervalSince1970;
double trainloss = 0, testLoss = 0;
double lasstrainloss = 0;
- (void)onestep{
    [networkLock lock];
    
    //进行batch轮训练
    double loss = 0;
    for (int i = 0; i < testNum; i++) {
        inputs[0] = testx1[i];
        inputs[1] = testx2[i];
        double output = network->forwardProp(inputs, 2);
        loss += 0.5 * pow(output - testy[i], 2);
    }
    testLoss = loss/testNum;
    
    loss = 0;
    int trainEpoch = 0;
    for(int n = 0; n < trainBatch; n++){
        for (int i = 0; i < trainNum; i++) {
            inputs[0] = trainx1[i];
            inputs[1] = trainx2[i];
            double output = network->forwardProp(inputs, 2);
            network->backProp(trainy[i]);
            loss += 0.5 * pow(output - trainy[i], 2);
            trainEpoch++;
            if((trainEpoch+1)%batch==0){
                network->updateWeights(learningRate, regularizationRate);
            }
        }
    }
    epoch += trainBatch;
    trainloss = loss/trainNum/trainBatch;
    
    double tmp1 = trainloss, tmp2 = testLoss;
    [self ui:^{
        [_lossView addLoss:tmp1 b:tmp2];
    }];
    
    [networkLock unlock];
    double now = [NSDate date].timeIntervalSince1970;
    speed = 1.0/(now - lastEpochTime);
    lastEpochTime = now;
    
    [self getHeatData];
    [self updateLabel];
}

- (void)updateLabel{
    [self ui:^{
        [_outputLabel setText:[NSString stringWithFormat:@"训练次数:%d", epoch]];
        [_lossLabel setText:[NSString stringWithFormat:@"训练误差:%.3f\n测试误差%.3f", trainloss, testLoss]];
        [_fpsLabel setText:[NSString stringWithFormat:@"fps:%d", speed]];
        [_ratioOfTrainingDataLabel setText:[NSString stringWithFormat:@"训练数据\n百分比：%d%%", (int)(ratioOfTrainingData*100)]];
        [_noiseLabel setText:[NSString stringWithFormat:@"噪声：%d", (int)(noise*100)]];
    }];
}

double lastTrainTime = 0;
- (void)train{
    while(always){
        //帧数控制
        if([NSDate date].timeIntervalSince1970 - lastTrainTime > 1.0/maxfps){
            lastTrainTime = [NSDate date].timeIntervalSince1970;
            [self onestep];
        }
        [NSThread sleepForTimeInterval:0.01/120];
    }
}
- (IBAction)buttonReset:(id)sender {
    [self reset];
}

- (IBAction)changeSwitch:(UISwitch *)sender {
    always = sender.on;
    lastEpochTime = (int)[NSDate date].timeIntervalSince1970;
    [self xiancheng:^{[self train];}];
}

CGFloat screenScale = [UIScreen mainScreen].scale;

- (void)viewDidLoad {
    [super viewDidLoad];
    initColor();
    [self updateDataset];
    [self reset];

}

MBProgressHUD *hud = [MBProgressHUD alloc];

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    NSString *message = @"";
    if (!error) {
        message = @"成功保存到相册";
        UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = imageView;
    }else {
        message = [error description];
    }
    hud.label.text = message;
    printf("%s\n", [message UTF8String]);
    [hud hideAnimated:YES afterDelay:1];
}

- (IBAction)longpressSavePhoto:(UILongPressGestureRecognizer *)sender {
    if(sender.state != UIGestureRecognizerStateBegan)return;
    UIAlertController * alert =
    [UIAlertController alertControllerWithTitle:@"保存到相册"
                                        message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction * cancel =
    [UIAlertAction actionWithTitle:@"取消"
                             style:UIAlertActionStyleDefault
                           handler:nil];
    
    UIAlertAction * ok =
    [UIAlertAction actionWithTitle:@"确定"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * _Nonnull action) {
                               hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                               hud.mode = MBProgressHUDModeAnnularDeterminate;
                               hud.label.text = @"生成图像中";
                               [self xiancheng:^{
                                   [self generateBigOutputImage];
                                   UIImageWriteToSavedPhotosAlbum(bigOutputImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
                               }];
                           }];

    [alert addAction:cancel];
    [alert addAction:ok];
    
    alert.view.backgroundColor = [UIColor whiteColor];
    
    alert.modalPresentationStyle = UIModalPresentationPopover;
    alert.popoverPresentationController.sourceRect = sender.view.bounds;
    alert.popoverPresentationController.sourceView = sender.view;
    alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    [self presentViewController:alert animated:YES completion:nil];
}

enum Dataset{Circle, Xor, TwoGaussian, Spiral};
Dataset dataset = Circle;
- (IBAction)initDataset:(UIButton *)sender {
    dataset = (Dataset)sender.tag;
    [self updateDataset];
}

vector<CALayer *> shadows;
- (void)setShadow:(UIView *)view selected:(BOOL)selected{
    if(selected){
        CALayer *shadowLayer = [[CALayer alloc] init];
        shadowLayer.frame = view.frame;
        shadowLayer.cornerRadius = 5;
        shadowLayer.shadowOffset = CGSizeMake(3, 3);
        shadowLayer.shadowColor = [UIColor blackColor].CGColor;
        shadowLayer.shadowRadius = 5.0;
        shadowLayer.shadowOpacity = 0.3;
        shadowLayer.backgroundColor = [UIColor grayColor].CGColor;
        [self.view.layer insertSublayer:shadowLayer atIndex:0];
        shadows.push_back(shadowLayer);
        view.alpha = 1;
    }else{
        view.alpha = 0.2;
    }
}

- (void)updateShadows{
    while(shadows.size()){
        [shadows.back() removeFromSuperlayer];
        shadows.pop_back();
    }
    [self setShadow:_circleButton selected:dataset == Circle];
    [self setShadow:_xorButton selected:dataset == Xor];
    [self setShadow:_twoGaussianButton selected:dataset == TwoGaussian];
    [self setShadow:_spiralButton selected:dataset == Spiral];
}


- (IBAction)changeActivation:(UIButton *)sender {
    NSMutableArray * data = [[NSMutableArray alloc]init];
    [data addObject:@"ReLU"];
    [data addObject:@"Tanh"];
    [data addObject:@"Sigmoid"];
    [data addObject:@"Linear"];
    
    TableViewController * tv = [[TableViewController alloc] init];
    [tv initWithData:data
           selection:activation
              sender:sender
            selected:^(int index) {
                activation = (ActivationFunction)index;
                [self reset];
                [sender setTitle:data[index] forState:UIControlStateNormal];
                [tv dismissViewControllerAnimated:NO completion:nil];
            }
     ];
    
    [self presentViewController:tv animated:YES completion:nil];
}

int lastLearningRateSelection = 4;
- (IBAction)changeLearningRate:(UIButton *)sender {
    NSMutableArray * data = [[NSMutableArray alloc]init];
    [data addObject:@"0.00001"];
    [data addObject:@"0.0001"];
    [data addObject:@"0.001"];
    [data addObject:@"0.003"];
    [data addObject:@"0.01"];
    [data addObject:@"0.03"];
    [data addObject:@"0.1"];
    [data addObject:@"0.3"];
    [data addObject:@"1"];
    [data addObject:@"3"];
    [data addObject:@"10"];
    
    TableViewController * tv = [[TableViewController alloc] init];
    [tv initWithData:data
           selection:lastLearningRateSelection
              sender:sender
            selected:^(int index) {
                lastLearningRateSelection = index;
                learningRate = [(NSString *)data[index] floatValue];
                [sender setTitle:data[index] forState:UIControlStateNormal];
                [tv dismissViewControllerAnimated:NO completion:nil];
            }
     ];
    
    [self presentViewController:tv animated:YES completion:nil];
}

- (IBAction)changeRegularization:(UIButton *)sender {
    NSMutableArray * data = [[NSMutableArray alloc]init];
    [data addObject:@"None"];
    [data addObject:@"L1"];
    [data addObject:@"L2"];
    
    TableViewController * tv = [[TableViewController alloc] init];
    [tv initWithData:data
           selection:regularization
              sender:sender
            selected:^(int index) {
                regularization = (RegularizationFunction)index;
                [sender setTitle:data[index] forState:UIControlStateNormal];
                [tv dismissViewControllerAnimated:NO completion:nil];
            }
     ];
    
    [self presentViewController:tv animated:YES completion:nil];
}

int lastRegularizationRateSelection = 0;
- (IBAction)changeRegularizationRate:(UIButton *)sender {
    NSMutableArray * data = [[NSMutableArray alloc]init];
    [data addObject:@"0"];
    [data addObject:@"0.001"];
    [data addObject:@"0.003"];
    [data addObject:@"0.01"];
    [data addObject:@"0.03"];
    [data addObject:@"0.1"];
    [data addObject:@"0.3"];
    [data addObject:@"1"];
    [data addObject:@"3"];
    [data addObject:@"10"];
    
    TableViewController * tv = [[TableViewController alloc] init];
    [tv initWithData:data
           selection:lastRegularizationRateSelection
              sender:sender
            selected:^(int index) {
                lastRegularizationRateSelection = index;
                regularizationRate = [(NSString *)data[index] floatValue];
                [sender setTitle:data[index] forState:UIControlStateNormal];
                [tv dismissViewControllerAnimated:NO completion:nil];
            }
     ];
    
    [self presentViewController:tv animated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [self resetNetwork];
    [self updateShadows];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

