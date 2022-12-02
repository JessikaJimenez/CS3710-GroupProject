import sys
class PacDotAddresses():

    SPRITE_ID_START = 0xC000
    def __init__(self):
        
        f = open("PacDotAddr.txt", "w")
        gridFile = open("grid.txt", "r")
        currentLine = 0

        for line in gridFile:
            if line == "0000000000000001\n":
                f.write("{0:016b}\n".format(currentLine + self.SPRITE_ID_START))
            currentLine += 1
        
        gridFile.close()
        f.close()

        



class CreateDat():
    ########## INDEXES ##########
    #############################
    PROGRAM_START = 0
    PROGRAM_END = 0xBFFF
    SPRITE_ID_START = 0xC000
    SPRITE_ID_END = 0xC4AF
    SPRITES_START = 0xC4B0
    SPRITES_END = 0xCC2F
    ##########################
    CAPMAN_POS_X = 0xCC30
    CAPMAN_POS_Y = 0xCC31
    CAPMAN_DIR = 0xCC32
    ##########################
    GHOST_POS_X = 0xCC33
    GHOST_POS_Y = 0xCC34 
    GHOST_DIR = 0xCC35 
    ##########################
    PACDOT_COUNT_INDEX = 0xCC36
    CAPMAN_STATE_INDEX = 0xCC37

    PACDOTS_START = 0xCD00
    PACDOTS_END   = 0xCDD5
    ##########################
    ##########################

    ##### STARTING VARIABLES ####
    #############################
    capPosX = 1
    capPosY = 2
    capDir  = 3

    ghostPosX = 4
    ghostPosY = 5
    ghostDir  = 6

    pacdotCount = 414
    capState    = 8

    


    def __init__(self):
        f = open("CapMan.dat", "w")
        numLines = 0
        lineTracker = 0
        print("Starting...")
        #### INSERT ASSEMLBY BINARY ###
        assemblyFile = open("capman.bin", "r")
        numAdresses = 0

        for line in assemblyFile:
            f.write(line)
            numLines += 1
            lineTracker += 1
            numAdresses += 1
        f.write("\n")
        assemblyFile.close()
        print("Finished Assembly Total Lines: {}".format(numLines))
        while(numLines < (self.PROGRAM_END - self.PROGRAM_START + 1)):
            f.write("0000000000000000" + "\n")
            numLines += 1
            lineTracker += 1

        ###############################
        #### INSERT GRID DATA ####
        gridFile = open("grid.txt", "r")
        numLines = 0

        for line in gridFile:
            f.write(line)
            numLines += 1
            lineTracker += 1
            numAdresses += 1

        gridFile.close()
        print("Sprite Ids finished Total Lines: {}".format(numLines))
        f.write("\n")
        while(numLines < (self.SPRITE_ID_END - self.SPRITE_ID_START + 1)):
            f.write("0000000000000000" + "\n")
            numLines += 1
            lineTracker += 1
        ###############################
        #### INSERT SPRITE DATA #######

        spritesFile = open("sprites.txt", "r")
        numLines = 0
        
        for x in spritesFile:
            line = x.split('#')[0]
            if(len(line) > 0):
                if(line != "\n"):
                    f.write(line)
                    numLines += 1
                    lineTracker += 1
                    numAdresses += 1

        gridFile.close()
        print("Sprites Finished Total Lines: {}".format(numLines))
        f.write("\n")
        while(numLines < (self.SPRITES_END - self.SPRITES_START + 1)):
            f.write("0000000000000000" + "\n")
            numLines += 1
            lineTracker += 1

##################################################################
##################################################################
        numLines = 0
        f.write('{0:016b}\n'.format(self.capPosX))
        f.write('{0:016b}\n'.format(self.capPosY))
        f.write('{0:016b}\n'.format(self.capDir))

        f.write('{0:016b}\n'.format(self.ghostPosX))
        f.write('{0:016b}\n'.format(self.ghostPosY))
        f.write('{0:016b}\n'.format(self.ghostDir))

        f.write('{0:016b}\n'.format(self.pacdotCount))
        f.write('{0:016b}\n'.format(self.capState))
        lineTracker += 8
        numAdresses += 8
        print("Added Locations, Total Lines: {}".format(8))

##################################################################
############## PAC DOT ADDRESSES #############################
        dotAddressFile = open("PacDotAddr.txt", "r")
        numLines = 0

        for x in dotAddressFile:
            f.write(x)
            lineTracker += 1
            numAdresses += 1
            numLines += 1
            

        dotAddressFile.close()
        print("Finished dotAddreses Total: {}".format(numLines))
##################################################################
##################################################################
        print("Writing Last 0s")
        
        numLines = 0
        while(numLines < ( 0x10000 - self.PACDOTS_END)):
            f.write("0000000000000000" + "\n")
            numLines += 1
            lineTracker += 1
        f.close()
        print("Finished")
        print(numAdresses)

def main():
    pac = PacDotAddresses()
    dat = CreateDat()

if __name__ == "__main__":
    main()
