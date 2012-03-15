
var minwage = function() {
    this.companies = [];
    this.maxPopulation = 100;
    this.laborSupply = 0;
    this.minWage = 0;
};
minwage.prototype.init = function() {
    var self = this;
    $('#laborSupplySlider').slider({
        min: 0, max: 1, step: 0.01,
        value: this.laborSupply,
        slide: function(evt, ui) {
            self.laborSupply = ui.value;
            $('#laborSupply').text(self.totalWorkers());
            self.reallocateResources();
            self.redraw();
        }
    });
    $('#minWageSlider').slider({
        min: 0, max: 26, step: 0.25,
        value: this.minWage,
        slide: function(evt, ui) {
            self.minWage = ui.value;
            $('#minWage').text(formatCurrency(self.minWage));
            self.reallocateResources();
            self.redraw();
        }
    });
    $('#randomize').click(function() {
        self.randomizeCompanies();
    });
    $('#less').click(function() {
        self.removeCompany();
    });
    $('#more').click(function() {
        self.addRandomCompany();
        self.reallocateResources();
        self.redraw();
    });
    $('#laborSupply').text(this.totalWorkers());
    $('#minWage').text(formatCurrency(self.minWage));
    this.addCompany(5, 10);
    this.addCompany(10, 5);
    this.addCompany(15, 3.33);
    this.addCompany(20, 2.5);
    this.addCompany(25, 2);
    this.redraw();
};
minwage.prototype.debug = function() {
    var self = this;
    console.log('labor supply', this.availableLaborSupply());
    $.each(this.companies, function(i, c) {
        console.log(c.profitability, c.wage(self.availableLaborSupply()));
    });
}
minwage.prototype.randomizeCompanies = function() {
    var len = this.companies.length;
    this.companies = [];
    for(var i = 0; i < len; i++) {
        this.addRandomCompany();
    }
    this.reallocateResources();
    this.redraw();
};
minwage.prototype.addRandomCompany = function() {
    this.addCompany(5 * Math.random() * 4 + 1, Math.random() * 9 + 1);
};
minwage.prototype.removeCompany = function() {
    this.companies.pop();
    this.reallocateResources();
    this.redraw();
};
minwage.prototype.totalWorkers = function() {
    return Math.round(this.laborSupply * this.maxPopulation);
};
minwage.prototype.totalEmployed = function() {
    var result = 0;
    $.each(this.companies, function(i, c) {
        result += c.workers;
    });
    return result;
};
minwage.prototype.totalUnemployed = function() {
    return this.totalWorkers() - this.totalEmployed();
};
minwage.prototype.availableLaborSupply = function() {
    //return this.totalUnemployed() / this.totalWorkers();
    return this.totalUnemployed() / this.maxPopulation;
};
minwage.prototype.addCompany = function(profitability, availability) {
    var c = new company(profitability, availability);
    this.companies.push(c);
    return c;
};
minwage.prototype.reallocateResources = function() {
    var self = this;
    $.each(this.companies, function(i, c) {
        c.workers = 0;
        c.minWage = self.minWage;
    });
    var laborSupply = this.availableLaborSupply();
    if(laborSupply == 0) {
        $.each(this.companies, function(i, c) {
            c.lastWage = c.wage(1);
        });
        return;
    }
    while(this.totalUnemployed() > 0) {
        var company = this.sortingHat(laborSupply);
        if(!company) {
            break;
        }
        company.workers++;
    }
};
minwage.prototype.sortingHat = function(laborSupply) {
    // Find the highest value company that is hiring
    var self = this;
    var pos = false;
    var bestWage = 0;
    $.each(this.companies, function(i, c) {
        var wage = c.wage(laborSupply);
        c.lastWage = wage;
        if(c.canHireWorker(laborSupply) && wage > bestWage) {
            bestWage = wage;
            pos = i;
        }
    });
    if(bestWage == 0) {
        return false;
    }
    return this.companies[pos];
};
minwage.prototype.redraw = function() {
    var self = this;
    
    var workersHtml = '';
    for(var i = 0; i < this.totalUnemployed(); i++) {
        workersHtml += '<img src="man32.png" /> ';
    }
    $('#workers').html(workersHtml);
    
    var companiesHtml = '';
    $.each(this.companies, function(i, c) {
        var companyWorkersHtml = '';
        for(var i = 0; i < c.workers; i++) {
            companyWorkersHtml += '<img src="man' + self.manSize(c.workers) + '.png?v=4" /> ';
        }
        companiesHtml += ''
            + '<div class="company">'
            + '    <div class="inner">'
            + '        <div class="icon">'
            + '             <div>Wages: <span class="wage">' + formatCurrency(c.lastWage) + '</span></div>'
            + '             <div class="note">Capacity: ' + formatCurrency(c.maxOutput()) + '</div>'
            + '             <div class="note">'+ c.workers +' x ' + formatCurrency(c.lastWage) + ' = ' + formatCurrency(c.actualOutput()) +'</div>'
            + '         </div>'
            + '        <div class="workers">' + companyWorkersHtml + '</div>'
            + '        <div class="clear"></div>'
            + '    </div>'
            + '</div>';
    });
    $('#companies').html(companiesHtml);
};
minwage.prototype.manSize = function(workers) {
    if(workers > 84) {
        return 11;
    } else if(workers > 55) {
        return 14;
    } else if (workers > 36) {
        return 18;
    } else if (workers > 21) {
        return 24;
    }
    return 32;
};

var company = function(profitability, availability) {
    this.profitability = profitability;
    this.availability = availability;
    this.workers = 0;
    this.minWage = 0;
    this.lastWage = this.wage(1);
};
company.prototype.wage = function(laborSupply) {
    var result = (this.profitability - this.minWage) * (1 - laborSupply) + this.minWage;
    if(this.workers == 0) {
        result = this.profitability;
    }
    result = Math.max(result, this.profitability / this.availability);
    return Math.max(result, this.minWage);
};
company.prototype.maxOutput = function() {
    return this.profitability * this.availability;
};
company.prototype.estimateOutput = function(laborSupply, workers) {
    return this.wage(laborSupply) * workers;
};
company.prototype.actualOutput = function() {
    return this.lastWage * this.workers;
};
company.prototype.canHireWorker = function(laborSupply) {
    return this.estimateOutput(laborSupply, this.workers + 1) <= this.maxOutput();
};

// Original:  Cyanide_7 (leo7278@hotmail.com)
// Web Site:  http://www7.ewebcity.com/cyanide7
// This script and many more are available free online at
// The JavaScript Source!! http://javascript.internet.com
function formatCurrency(num) {
    num = num.toString().replace(/\$|\,/g,'');
    if(isNaN(num))
        num = "0";
    sign = (num == (num = Math.abs(num)));
    num = Math.floor(num*100+0.50000000001);
    cents = num%100;
    num = Math.floor(num/100).toString();
    if(cents<10)
        cents = "0" + cents;
    for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)
        num = num.substring(0,num.length-(4*i+3))+','+
    num.substring(num.length-(4*i+3));
    return (((sign)?'':'-') + '$' + num + '.' + cents);
}
