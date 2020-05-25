//
//  ViewController.m
//  uitest
//
//  Created by 汪炳权 on 19.05.20.
//  Copyright © 2020 汪炳权. All rights reserved.
//

#import "ViewController.h"
#import "PhoneNetSDK.h"
#import "LBDevice.h"
@interface ViewController ()
@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, strong) NSMutableString * infoText;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    
    [[PhoneNetManager shareInstance] settingSDKLogLevel:PhoneNetSDKLogLevel_DEBUG];
    

//

    
    [self.view addSubview:self.textView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.textView.text = self.infoText;
        [self beginTask];
    });
    
}

-(void)beginTask{
    
    [self.infoText appendString:@"Start ping:www.xlgxapp.com...\n"];
    self.textView.text = self.infoText;
    [[PhoneNetManager shareInstance] netStartPing:@"www.xlgxapp.com" packetCount:4 pingResultHandler:^(PhoneNetPingStatus status, NSString * _Nullable pingres) {
       
        [self.infoText appendString:[NSString stringWithFormat:@"%@\n",pingres]];
        self.textView.text = self.infoText;
        
        if(status == PhoneNetPingStatusFinished){
            [self.infoText appendString:@"End ping\n"];
            self.textView.text = self.infoText;
            [self pingBaidu];
        }
    }];
}


-(void)pingBaidu{
    [self.infoText appendString:@"Start ping:www.baidu.com...\n"];
    self.textView.text = self.infoText;
    [[PhoneNetManager shareInstance] netStartPing:@"www.baidu.com" packetCount:4 pingResultHandler:^(PhoneNetPingStatus status, NSString * _Nullable pingres) {
        [self.infoText appendString:[NSString stringWithFormat:@"%@\n",pingres]];
        self.textView.text = self.infoText;
        
        if(status == PhoneNetPingStatusFinished){
            [self.infoText appendString:@"End ping\n"];
            self.textView.text = self.infoText;
            [self startTraceRoute];
        }
        
    }];
}

-(void)startTraceRoute{
    [self.infoText appendString:@"Start traceroute:www.xlgxapp.com...\n"];
    self.textView.text = self.infoText;
        [[PhoneNetManager shareInstance] netStartTraceroute:@"www.xlgxapp.com" tracerouteResultHandler:^(Enum_Traceroute_Status status, NSString * _Nullable tracertRes) {
            
        [self.infoText appendString:[NSString stringWithFormat:@"%@\n",tracertRes]];
        self.textView.text = self.infoText;
            
            
        if(status == Enum_Traceroute_Status_finish){
            [self.infoText appendString:@"End traceroute\n"];
            self.textView.text = self.infoText;
            [self endTask];
        }
            
        
    }];
}

-(void)endTask{
    NSLog(@"完成\n");
}



-(NSMutableString *)infoText{
    
    if(!_infoText){
        _infoText = [[NSMutableString alloc]initWithString:@"开始诊断\n"];
        [_infoText appendString:[NSString stringWithFormat:@"应用名称:%@\n",[LBDevice appName]]];
        [_infoText appendString:[NSString stringWithFormat:@"应用版本:%@\n",[LBDevice appVersion]]];
        [_infoText appendString:@"机器类型:iOS\n"];
        [_infoText appendString:[NSString stringWithFormat:@"系统版本:%@\n",[LBDevice systemVersion]]];
        [_infoText appendString:[NSString stringWithFormat:@"设备号:%@\n",[LBDevice deviceId]]];
        [_infoText appendString:[NSString stringWithFormat:@"运营商:%@\n",[LBDevice carrierName]]];
        [_infoText appendString:[NSString stringWithFormat:@"网络类型:%@\n",[LBDevice networkType]]];
        [_infoText appendString:[NSString stringWithFormat:@"wifi强度:%@\n",[LBDevice wifiSignalStrength]]];
    }
    return _infoText;
}

@end
