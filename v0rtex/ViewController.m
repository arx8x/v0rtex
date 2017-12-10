//
//  ViewController.m
//  v0rtex
//
//  Created by ninja on 12/10/17.
//  Copyright © 2017 ninja. All rights reserved.
//
#include <mach/mach.h>
#import "IOKit/IOKitLib.h"
//#import "IOKit/IOTypes.h"
#import "v0rtex.h"
#import "common.h"
#import "ViewController.h"
#include "sys/utsname.h"
#include "sys/sysctl.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *xploitButton;

@end

@implementation ViewController






- (IBAction)xploit:(id)sender
{
    LOG("Button Pressed, exploiting");
    _xploitButton.titleLabel.text = @"Exploiting";
    _xploitButton.enabled = FALSE;
    task_t tfp0 = MACH_PORT_NULL;
    kptr_t kslide = 0;
    kern_return_t ret = v0rtex(&tfp0, &kslide);
    
    // XXX
    if(ret == KERN_SUCCESS)
    {
        extern kern_return_t mach_vm_read_overwrite(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize);
        uint32_t magic = 0;
        mach_vm_size_t sz = sizeof(magic);
        ret = mach_vm_read_overwrite(tfp0, 0xfffffff007004000 + kslide, sizeof(magic), (mach_vm_address_t)&magic, &sz);
        LOG("mach_vm_read_overwrite: %x, %s", magic, mach_error_string(ret));
        
        FILE *f = fopen("/var/mobile/test.txt", "w");
        
        
//        LOG("file: %p", f);
//
//        NSMutableDictionary *batteryData = [NSMutableDictionary new];
//        CFMutableDictionaryRef pdict = IOServiceMatching("IOPMPowerSource");
//        io_service_t powerservice = IOServiceGetMatchingService(kIOMasterPortDefault, pdict);
//
//        CFMutableDictionaryRef powerData;
//        kern_return_t pret = IORegistryEntryCreateCFProperties(powerservice, &powerData, 0, 0);
//
//        if(pret == KERN_SUCCESS)
//        {
//            batteryData = (__bridge NSMutableDictionary*)powerData;
        //
//
//        }
//        else
//        {
//            LOG("Failed to read IOData");
//        }
        NSMutableString *deviceData = [[NSMutableString alloc] initWithFormat:@"%p\n", f];
        int prop[2] = {CTL_HW, HW_MODEL};
        char val[10];
        size_t size = sizeof(val);
        if(!sysctl(prop, 2, (void *)val, &size, NULL, 0))
        {
            [deviceData appendFormat:@"Platform : %s\n", val];
        }
        struct utsname sysinfo;
        if(!uname(&sysinfo))
        {
            [deviceData appendFormat:@"Device : %s\n", sysinfo.machine];
            [deviceData appendFormat:@"Kernel : %s", sysinfo.version];
        }
        
        
        
        [[[UIAlertView alloc] initWithTitle:@"EXploit Succesful" message:[[NSString alloc] initWithFormat:@"%@", deviceData] delegate:nil cancelButtonTitle:@"Clover Wins" otherButtonTitles:nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Exploit Failed" message:@"Reboot and try again" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    LOG("view loaded");

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
