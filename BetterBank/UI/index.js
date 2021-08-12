$(document).ready(function(){
    function display(bool) {
        if (bool) {
            $(".bankPanel").show();
        } else {
            $(".bankPanel").hide();
        }
    }

    function AnimationDisplay(bool) {
        if (bool) {
            setTimeout(function(){jQuery('.bankPanel').fadeIn('show')}, 600);
        } else {
            $(".bankPanel").fadeOut(400);
        }
    }

    display(false)

    window.addEventListener('message', function(event) {
        var item = event.data;
        if (item.type === "ui") {
            if (item.status == true) {
                AnimationDisplay(true)
            } else {
                AnimationDisplay(false)
            }
        }
        else if (item.type === "reset") {
            $("#islemler").html("")
            $(".faturalar").html("")
        }
        else if (item.type === "balance") {
            $(".playerName").html(event.data.player)
            $("#playerMoneyAmount").html(addCommas((String(event.data.balance))))
            $("#playerMoneyAmount").append(",00")
            $("#playerMoneyAmount").prepend("$")
            $(".playerIBAN").html(event.data.IBAN)
        }
        else if (item.type === "paraYatirma") {
            if (item.ekle) {
                addSonIslem("<div class= \"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-chart-line\"></i></div><div class=\"islemBilgiHolder\"><p class=\"islemTuruText\">Para Yatırma</p><a class=\"yatirilanMiktar\">" + String(item.miktar) +"</a><span class=\"islemZaman\">" + String(item.neZaman) + "</span></div></div>")
            }
            if(item.animasyon == true) {
                $(".dark").css({ "display":"block"})
                $("#basarili").html("<i class=\"fal fa-check-circle\"></i><br><p class=\"basariliText\"></p>")
                $(".basariliText").text("Paranız Yatırıldı")
                setTimeout(function(){jQuery('.dark').fadeIn(1000)}, 500);
                setTimeout(function(){jQuery('.dark').fadeOut(1000)}, 3000);
                $(".dark").css({ "display":"none"})
            }
        }
        else if (item.type === "paraCekme") {
            if(item.ekle) {
                addSonIslem("<div class=\"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-chart-line-down\"></i></div><div class=\"islemBilgiHolder\"><p class=\"islemTuruText\">Para Çekme</p><a class=\"cekilenMiktar\">" + String(item.miktar) +"</a><span class=\"islemZaman\">" + String(item.neZaman) + "</span></div></div>")
            }
            if(item.animasyon) {
                $(".dark").css({ "display":"block"})
                $("#basarili").html("<i class=\"fal fa-check-circle\"></i><br><p class=\"basariliText\"></p>")
                $(".basariliText").text("Paranız Çekildi.")
                setTimeout(function(){jQuery('.dark').fadeIn(1000)}, 500);
                setTimeout(function(){jQuery('.dark').fadeOut(1000)}, 3000);
                $(".dark").css({ "display":"none"})
            }
        }
        else if (item.type === "gidenTransfer") {
            //addSonIslem("<div class=\"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-exchange\"></i></div><div class=\"islemBilgiHolder\"><div class=\"tranferUstHolder\"><p class=\"islemTuruText\" >Transfer <a class=\"gonderenGonderilenBilgi\">" + String(item.kimden) + "</a></p></div><a class=\"transferGidenMiktar\">" + String(item.miktar) +"</a><span class=\"islemZaman\">" + String(item.neZaman) + "</span></span></div></div>")
            if (item.ekle) {
                addSonIslem("<div class=\"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-exchange\"></i></div><div class=\"islemBilgiHolder\"><p class=\"islemTuruText\" >" + String(item.kimden) + "</p><span class=\"transferGidenMiktar\">" + String(item.miktar) + "</span><span class=\"islemZaman\">" + String(item.neZaman) +"</span></span></div></div>")
            }
            if(item.animasyon) {
                $(".dark").css({ "display":"block"})
                $("#basarili").html("<i class=\"fal fa-check-circle\"></i><br><p class=\"basariliText\"></p>")
                $(".basariliText").text("Transfer Yapıldı.")
                setTimeout(function(){jQuery('.dark').fadeIn(1000)}, 500);
                setTimeout(function(){jQuery('.dark').fadeOut(1000)}, 3000);
                $(".dark").css({ "display":"none"})
            }
        }
        else if (item.type === "gelenTransfer") {
            if(item.ekle){
                addSonIslem("<div class=\"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-exchange\"></i></div><div class=\"islemBilgiHolder\"><p class=\"islemTuruText\" >" + String(item.kimden) + "</p><span class=\"transferGelenMiktar\">" + String(item.miktar) + "</span><span class=\"islemZaman\">" + String(item.neZaman) +"</span></span></div></div>")
            }
        }
        else if (item.type === "FaturaGiden") {
            if(item.ekle){
                addSonIslem("<div class=\"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-file-invoice-dollar\"></i></div><div class=\"islemBilgiHolder\"><p class=\"islemTuruText\" >" + String(item.kimden) + "</p><span class=\"transferGidenMiktar\">" + String(item.miktar) + "</span><span class=\"islemZaman\">" + String(item.neZaman) +"</span></span></div></div>")
            }
            if(item.animasyon) {
                $(".dark").css({ "display":"block"})
                $("#basarili").html("<i class=\"fal fa-check-circle\"></i><br><p class=\"basariliText\"></p>")
                $(".basariliText").text("Fatura Ödendi.")
                setTimeout(function(){jQuery('.dark').fadeIn(1000)}, 500);
                setTimeout(function(){jQuery('.dark').fadeOut(1000)}, 3000);
                $(".dark").css({ "display":"none"})
            }
            //addSonIslem("<div class=\"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-exchange\"></i></div><div class=\"islemBilgiHolder\"><div class=\"tranferUstHolder\"><p class=\"islemTuruText\" >Transfer <a class=\"gonderenGonderilenBilgi\">" + String(item.kimden) + "</a></p></div><a class=\"transferGelenMiktar\">" + String(item.miktar) +"</a><span class=\"islemZaman\">" + String(item.neZaman) + "</span></span></div></div>")    
        }
        else if (item.type === "FaturaGelen") {
            if(item.ekle){
                addSonIslem("<div class=\"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-file-invoice-dollar\"></i></div><div class=\"islemBilgiHolder\"><p class=\"islemTuruText\" >" + String(item.kimden) + "</p><span class=\"transferGelenMiktar\">" + String(item.miktar) + "</span><span class=\"islemZaman\">" + String(item.neZaman) +"</span></span></div></div>")
            }
            //addSonIslem("<div class=\"islem\"><div class=\"islemIconHolder\"><i class=\"fal fa-exchange\"></i></div><div class=\"islemBilgiHolder\"><div class=\"tranferUstHolder\"><p class=\"islemTuruText\" >Transfer <a class=\"gonderenGonderilenBilgi\">" + String(item.kimden) + "</a></p></div><a class=\"transferGelenMiktar\">" + String(item.miktar) +"</a><span class=\"islemZaman\">" + String(item.neZaman) + "</span></span></div></div>")    
        }
        else if(item.type === "fatura") {
            AddFatura("<div class=\"fatura\"><span class=\"faturaTarih\">" + item.neZaman + "</span><button type=\"button\" class=\"faturaOdeButton\">Öde</button><p class=\"faturaGonderenIsım\">" + item.senderName + "</p><span class=\"faturaAciklama\">" + item.label + "</span><span class=\"faturaDurum\">Beklemede</span><span class=\"faturaUcret\">" + "$" + (addCommas(String(item.amount))) + ",00" + "</span></div>")
        }
        else if(item.type === "faturaSil") {
            $("span:contains('" + item.label + "')").parent().remove()
        }
        else if(item.type === "hata") {
            BasarisizIslemGoster()
        }
    })

    $("#cikis").click(function() {
        $.post('http://BetterBank/exit', JSON.stringify({}));
        return
    })

    const checkbox = document.getElementById("toggledark")

    checkbox.addEventListener('change', ()=> {
        $(".bankPanel").toggleClass('darkness');
        $("button").toggleClass("darkness");
        $("a").toggleClass("darkness");
        $(".islemZaman").toggleClass("darkness");
        $("#islemler").toggleClass("darkness");
        $(".textislemler").toggleClass("darkness");
        $("#basarili").toggleClass("darkness");
        $(".fatura").toggleClass("darkness");
    });
    
    $("#parayiYatir").click(function(e) {
        var duzenlenmisAmount = "$" + addCommas(String($("#yatirText").val())) + ",00";

        $.post('http://BetterBank/deposit', JSON.stringify({
            IBAN: $(".playerIBAN").text(),
            islem: 'paraYatirma',
            amount: $("#yatirText").val(),
            neZaman: GetDateAndTime(),
            kimden: '',
            duzenlenmisAmount: duzenlenmisAmount
        }));
    });

    $("#paraCek").click(function(e) {
        var duzenlenmisAmount = "$" + addCommas(String($("#cekText").val())) + ",00";

        $.post('http://BetterBank/withdraw', JSON.stringify({
            IBAN: $(".playerIBAN").text(),
            islem: 'paraCekme',
            amount: $("#cekText").val(),
            neZaman: GetDateAndTime(),
            kimden: '',
            duzenlenmisAmount: duzenlenmisAmount
        }));
    });

    $("#IBANParaGonder").click(function(e) {
        let IBANval = $("#targetIBAN").val()
        let miktar = $("#targetAmount").val()
        
        let senderIBAN = $(".playerIBAN").text()

        var duzenlenmisAmount = "$" + addCommas(String(miktar)) + ",00";

        if (IBANval != "" && miktar > 0 && IBANval != senderIBAN)
        {
            $.post('http://BetterBank/transfer', JSON.stringify({
                IBANTarget: IBANval,
                amount: miktar,
                targetIslem: 'gelenTransfer',
                senderIBAN: senderIBAN,
                senderIslem: 'gidenTransfer',
                neZaman: GetDateAndTime(),
                duzenlenmisAmount: duzenlenmisAmount
            }));
        }
    });

    $(document).on('click', '.faturaOdeButton', function () {
        var tarih = $(this).prev().text()        // tarih
        var label = $(this).next().next().text() // label
        var duzenlenmisAmount = $(this).next().next().next().next().text() // Duzenlenmiş

        $.post('http://BetterBank/payBill', JSON.stringify({
            label: label,
            tarih: tarih,
            playerIBAN: $(".playerIBAN").text(),
            duzenlenmisAmount: duzenlenmisAmount
        }));
    });

    function addCommas(inputText) {
        // pattern works from right to left
        var commaPattern = /(\d+)(\d{3})(\.\d*)*$/;
        var callback = function (match, p1, p2, p3) {
            return p1.replace(commaPattern, callback) + '.' + p2 + (p3 || '');
        };
        return inputText.replace(commaPattern, callback);
    }

    function addSonIslem(inputText) {
        $("#islemler").html($.parseHTML(((inputText)) + $("#islemler").html()))
    }

    function AddFatura(inputText) {
        $(".faturalar").html($.parseHTML(((inputText)) + $(".faturalar").html()))
    }

    function GetDateAndTime() {
        
        var tarih = new Date();
        return anlik = (("0" + tarih.getDate()).slice(-2) + "-" + ("0" + (tarih.getMonth()+1)).slice(-2)  + "-" + tarih.getFullYear() + " " + ("0" + tarih.getHours()).slice(-2) + ":" + ("0" + tarih.getMinutes()).slice(-2))
    }

    function BasarisizIslemGoster() {
        $(".dark").css({ "display":"block"})
        $("#basarili").html("<i class=\"fal fa-times-circle\"></i><br><p class=\"basariliText\"></p>")
        $(".basariliText").text("İşlem gerçekleştirilemedi.")
        setTimeout(function(){jQuery('.dark').fadeIn(1000)}, 500);
        setTimeout(function(){jQuery('.dark').fadeOut(1000)}, 3000);
        $(".dark").css({ "display":"none"})
    }


});