#!/usr/bin/env python3

'''
Disk encryption
-----------------

Author      :   Jair Gonzalez

Requirements:   bundle storage-utils

'''

import pycryptsetup

def log(level, txt):
    ''' log callback '''
    if level == pycryptsetup.CRYPT_LOG_ERROR:
        print(txt, end="")
    return

def askyes(txt):
    ''' askyes callback '''
    print("Question:", txt)
    return 1

def get_cryptsetup_obj(device, map_name):
    ''' Initialize and return a CryptSetup object '''
    crs = pycryptsetup.CryptSetup(
        device=device,
        name=map_name,
        yesDialog=askyes,
        logFunc=log)
    crs.debugLevel(pycryptsetup.CRYPT_DEBUG_NONE)
    return crs

def encrypt_and_activate_device(device, passphrase, map_name):
    ''' Use CryptSetup to encrypt, initialize and activate/map a device '''
    crs = get_cryptsetup_obj(device, map_name)
    crs.luksFormat(cipher="aes", cipherMode="xts-plain64", keysize=512, hashMode="sha256")
    print("addKeyVK:", crs.addKeyByVolumeKey(newPassphrase=passphrase))
    activate_device(device, passphrase, map_name)

def activate_device(device, passphrase, map_name):
    ''' Use CryptSetup to activate/map a device '''
    crs = get_cryptsetup_obj(device, map_name)
    print("activate:", crs.activate(map_name, passphrase=passphrase))

def close_device(map_name):
    ''' Use CryptSetup to close a mapped device '''
    crs = get_cryptsetup_obj(None, map_name)
    print("deactivate:", crs.deactivate())

def add_passphrase_to_device(device, passphrase, newPassphrase):
    ''' Use CryptSetup to add a passphrase to a LUKS encrypted device '''
    crs = get_cryptsetup_obj(device, None)
    print("addKeyP:", crs.addKeyByPassphrase(passphrase, newPassphrase))

def remove_passphrase_from_device(device, passphrase):
    ''' Use CryptSetup to remove a passphrase from a LUKS encrypted device '''
    crs = get_cryptsetup_obj(device, None)
    print("removeKeyP:", crs.removePassphrase(passphrase))
