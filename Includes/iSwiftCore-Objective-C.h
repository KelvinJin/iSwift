//
//  Objective-C-Map.h
//  iSwiftCore
//
//  Created by Jin Wang on 24/02/2016.
//  Copyright © 2016 Uthoft. All rights reserved.
//

#ifndef Objective_C_Map_h
#define Objective_C_Map_h

#import <unistd.h>
#import <fcntl.h>

int c_execl(const char *filename, const char *arg0);
int c_fcntl(int fd, int cmd, int value);

inline int c_fcntl(int fd, int cmd, int value) {
    return fcntl(fd, cmd, value);
}

inline int c_execl(const char *filename, const char *arg0) {
    return execl(filename, arg0, NULL);
}

#endif /* Objective_C_Map_h */
