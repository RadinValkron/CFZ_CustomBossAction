Config = {}

Config.TpCoords = vector3(-811.84393310547, 175.19441223145, 76.745376586914)
Config.heading = 111.54900360107

Config.JobManagement = {
    ['police'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = false,
        markers = {
            { pos = vector3(447.9442, -973.025, 30.689), dist = 0.6 }
        }
    },
    ['nopo'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(447.9442, -973.025, 30.689), dist = 0.6 }
        }
    },
    ['rahvar'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = false,
        markers = {
            { pos = vector3(447.9442, -973.025, 30.689), dist = 0.6 }
        }
    },
    ['bank'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(140.7627, -1061.67, 22.960), dist = 0.6 }
        }
    },
    ['weazel'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(-575.02740478516, -938.41497802734, 28.817653656006), dist = 0.6 }
        }
    },
    ['artesh'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = false,
        markers = {
            { pos = vector3(-2354.36, 3256.729, 92.903), dist = 0.6 },
            { pos = vector3(-81.0121, -802.849, 243.40), dist = 0.6 }
        }
    },
    ['catcafe'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(140.7627, -1061.67, 22.960), dist = 0.6 }
        }
    },
    ['dadgostari'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(251.3405, -1100.31, 36.154), dist = 0.6 }
        }
    },
    ['sheriff'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = false,
        markers = {
            { pos = vector3(-1620.65, -1027.33, 13.162), dist = 0.6 }
        }
    },
    ['fbi'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(-2275.43, 367.3090, 179.83), dist = 0.6 }
        }
    },
    ['sepah'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = false,
        markers = {
            { pos = vector3(725.9978, 652.3940, 128.91), dist = 0.6 }
        }
    },
    ['casino'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(955.4287, 56.34017, 75.442), dist = 0.6 }
        }
    },
    ['mecano'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(886.3671, -2101.45, 34.888), dist = 0.6 }
        }
    },
    ['mechanic'] = {
        allowedGrades = {'boss', 'deputyboss'},
        allowUniform = true,
        markers = {
            { pos = vector3(-338.876, -157.807, 44.587), dist = 0.6 }
        }
    }
}

Config.JobLimits = {
    police      = 9,
    nopo        = 5,
    rahvar      = 6,
    sheriff     = 5, 
    fbi         = 7, 
    bank        = 4,  
    weazel      = 5, 
    artesh      = 12, 
    catcafe     = 4,   
    dadgostari  = 6,
    sepah  = 6,
    casino = 5,
    mecano = 6,
    mechanic = 7

}


Config.Webhook_JobLogs = "https://discord.com/api/webhooks/1416822212627009576/YeMS0FD7e-yUbDWtarLOyvJJAAWbwgaT_Unn2yz4NX7hmMMaQP4YvTVEV3hQbpdyR1mA"


Config.MaleDefault = {
    ['bproof_2'] = 0,
    ['helmet_2'] = -1,
    ['chain_2'] = 0,
    ['shoes_1'] = 34,
    ['face_1'] = 0,
    ['age_1'] = 0,
    ['complexion_1'] = 0,
    ['lipstick_4'] = 0,
    ['eyebrows_2'] = 10,
    ['decals_1'] = 0,
    ['glasses_1'] = -1,
    ['arms'] = 15,
    ['bproof_1'] = 0,
    ['makeup_4'] = 0,
    ['hair_color_2'] = 0,
    ['bags_2'] = 0,
    ['watches_1'] = -1,
    ['moles_2'] = 1,
    ['lipstick_3'] = 0,
    ['moles_1'] = 0,
    ['eyebrows_4'] = 12,
    ['arms_2'] = 0,
    ['pants_1'] = 61,
    ['torso_1'] = 15,
    ['torso_2'] = 0,
    ['hair_1'] = 10,
    ['hair_2'] = 0,
    ['hair_color_1'] = 0,
    ['lipstick_1'] = 0,
    ['face_2'] = 21,
    ['beard_3'] = 0,
    ['helmet_1'] = -1,
    ['pants_2'] = 1,
    ['makeup_2'] = 0,
    ['eye_color'] = 0,
    ['mask_1'] = 0,
    ['ears_1'] = -1,
    ['eyebrows_1'] = 0,
    ['glasses_2'] = -1,
    ['bags_1'] = 0,
    ['chain_1'] = 0,
    ['makeup_1'] = 0,
    ['makeup_3'] = 0,
    ['age_2'] = 0,
    ['beard_4'] = 0,
    ['watches_2'] = -1,
    ['complexion_2'] = 1,
    ['decals_2'] = 0,
    ['eyebrows_3'] = 12,
    ['ears_2'] = -1,
    ['face_3'] = 5,
    ['beard_2'] = 10,
    ['tshirt_2'] = 0,
    ['mask_2'] = 2,
    ['beard_1'] = 0,
    ['sex'] = 0,
    ['lipstick_2'] = 0,
    ['tshirt_1'] = 15,
    ['skin'] = 12,
    ['shoes_2'] = 0
}
Config.FemaleDefault = {
    ['bproof_2'] = 0,
    ['helmet_2'] = -1,
    ['chain_2'] = 0,
    ['shoes_1'] = 35,
    ['face_1'] = 0,
    ['arms'] = 15,
    ['complexion_1'] = 0,
    ['lipstick_4'] = 0,
    ['age_1'] = 0,
    ['eyebrows_2'] = 10,
    ['glasses_1'] = -1,
    ['decals_1'] = 0,
    ['bproof_1'] = 0,
    ['torso_2'] = 0,
    ['makeup_4'] = 0,
    ['bags_2'] = 0,
    ['hair_color_2'] = 0,
    ['moles_2'] = 1,
    ['lipstick_3'] = 20,
    ['moles_1'] = 0,
    ['eyebrows_4'] = 12,
    ['arms_2'] = 0,
    ['pants_1'] = 9,
    ['torso_1'] = 16,
    ['watches_1'] = -1,
    ['hair_1'] = 30,
    ['hair_2'] = 0,
    ['hair_color_1'] = 0,
    ['eyebrows_1'] = 1,
    ['face_2'] = 21,
    ['beard_3'] = 0,
    ['helmet_1'] = -1,
    ['pants_2'] = 12,
    ['makeup_2'] = 10,
    ['glasses_2'] = -1,
    ['lipstick_1'] = 3,
    ['ears_1'] = -1,
    ['mask_1'] = 0,
    ['eye_color'] = 0,
    ['bags_1'] = 0,
    ['chain_1'] = 0,
    ['makeup_1'] = 5,
    ['makeup_3'] = 0,
    ['age_2'] = 0,
    ['beard_4'] = 0,
    ['skin'] = 12,
    ['watches_2'] = -1,
    ['decals_2'] = 0,
    ['complexion_2'] = 1,
    ['ears_2'] = -1,
    ['eyebrows_3'] = 26,
    ['beard_2'] = 0,
    ['face_3'] = 6,
    ['mask_2'] = 2,
    ['beard_1'] = 0,
    ['sex'] = 1,
    ['lipstick_2'] = 10,
    ['tshirt_2'] = 0,
    ['tshirt_1'] = 15,
    ['shoes_2'] = 0
}