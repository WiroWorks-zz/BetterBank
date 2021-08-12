Config = {}

Config.UIOpener = 'atm'  -- Banka menüsü hangi kodu yazınca açılsın

Config.MaxSonIslem = 20   -- Oyuncu bankayı açtığında maksimum kaç tane son işlem yüklensin maksimum 20 girilebilir

Config.dbMinFiyat = 1000  -- bir işlemin database'e eklenmesi için gereken minimum fiyatı belirler database'inizi şişirmeyi önler serverınızın ekonomisine göre ayarlayabilirsiniz

Config.anlikSonIslemEkleMin = 1000  -- Bir son işlemin anlık olarak son işlemlere eklenmesi için gereken minumum tutar

Config.openBankWithCom = true -- Bankanın E'ye basılarak mı yoksa komut yazılarak mı açılacağını belirler false kalması optimizasyon için tavsiye edilir

Config.atmYokMSG = "Yakınınızda ATM Yok." -- Oyuncu ATM'yi açmaya çalıştığında yakınında ATM yok ise gösterilecek hatadaki mesaj

Config.Banks = {
    {name = "Banka", id = 108, Location = vector3(150.266, -1040.203, 29.374)},
    {name = "Banka", id = 108, Location = vector3(-1212.980, -330.841, 37.787)},
    {name = "Banka", id = 108, Location = vector3(-2962.582, 482.627, 15.703)},
    {name = "Banka", id = 108, Location = vector3(-112.202, 6469.295, 31.626)},
    {name = "Banka", id = 108, Location = vector3(-351.534, -49.529, 49.042)},
    {name = "Banka", id = 108, Location = vector3(241.727, 220.706, 106.286)},
    {name = "Banka", id = 108, Location = vector3(1175.0643310547, 2706.6435546875, 38.094036102295)},
    {name = "Banka", id = 108, Location = vector3(314.56, -278.28, 54.17)},
}

Config.Atms = {
    [1] = -1126237515,
    [2] = 506770882,
    [3] = -870868698,
    [4] = 150237004,
    [5] = -239124254,
    [6] = -1364697528,
}