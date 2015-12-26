




#define PREFS_DEFAULTS_PATH @"/Library/PreferenceBundles/CelloPrefs.bundle"

%ctor //syncronize cello default prefs
{
    NSBundle *bundle = [NSBundle bundleWithPath:PREFS_DEFAULTS_PATH];
    NSDictionary *prefDefaults = [NSDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"prefsDefaults" ofType:@".plist"]];
    
    for (NSString *key in prefDefaults) {
        
        NSString *application = @"com.apple.Music";
        
        id currentValue = (id)CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key,
                                                                          (__bridge CFStringRef)application));
        
        if (currentValue == nil) { //dont overwrite
            CFPreferencesSetAppValue((__bridge CFStringRef)key,
                                     (__bridge CFPropertyListRef)[prefDefaults valueForKey:key],
                                     (__bridge CFStringRef)application);

        }
        
        
    }
    
    //syncronize so we can read right away
    CFPreferencesAppSynchronize((__bridge CFStringRef)@"com.apple.Music");
    
}




