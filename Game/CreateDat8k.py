import sys
class PacDotAddresses():

    SPRITE_ID_START = 0x1000
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
    PROGRAM_END = 0x0FFF
    SPRITE_ID_START = 0x1000
    SPRITE_ID_END = 0x14AF
    SPRITES_START = 0x14B0
    SPRITES_END = 0x1C2F
    ##########################
    CAPMAN_POS_X = 0x1C30
    CAPMAN_POS_Y = 0x1C31
    CAPMAN_DIR = 0x1C32
    ##########################
    GHOST_POS_X = 0x1C33
    GHOST_POS_Y = 0x1C34 
    GHOST_DIR = 0x1C35 
    ##########################
    PACDOT_COUNT_INDEX = 0x1C36

    PACDOTS_START = 0x1C37
    PACDOTS_END   = 0x1DD4
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
        f = open("CapMan8k.dat", "w")
        numLines = 0
        lineTracker = 0
        print("Starting...")
        #### INSERT ASSEMLBY BINARY ###
        assemblyFile = open("capman 8k.bin", "r")
        numAdresses = 0

        for line in assemblyFile:
            f.write(line)
            numLines += 1
            lineTracker += 1
            numAdresses += 1
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
        lineTracker += 7
        numAdresses += 7
        numLines += 1
        print("Added Locations, Total Lines: {}".format(numLines))

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
        while(numLines < ( 0x1FFF - self.PACDOTS_END)):
            f.write("0000000000000000" + "\n")
            numLines += 1
            lineTracker += 1
        f.close()
        print("Finished")
        print("Total Memory Used: " + str(numAdresses))
        print("Total Lines: " + str(lineTracker))

def main():
    pac = PacDotAddresses()
    dat = CreateDat()

if __name__ == "__main__":
    main()
