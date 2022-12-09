# The Bayesian hierarchical model for year 2018
uhi = read.csv("desktop/STATS 506/ee_cb_uhi.csv")
uhi = uhi[uhi$yyyymm==2018,]
uhi = subset(uhi,select=-c(2))
names(uhi)[1] <- paste("county_fips")
climate = read.csv("desktop/STATS 506/ee_cb_climate.csv")
climate = climate[substr(climate$yyyymm,1,4)=="2018",]
climate = aggregate(climate,by=list(climate$county),FUN="mean")
climate = subset(climate,select=-c(1,3,5,6,7))
names(climate)[1] <- paste("county_fips")
insurance = read.csv("desktop/STATS 506/us_insurance.csv")
insurance = insurance[insurance$Year==2018,]
insurance = subset(insurance,select=-c(1,5,6,9,11,13,15))
insurance = subset(insurance,select=-c(2,3,4,5,6))
asthma = read.csv("desktop/STATS 506/asthma.csv")
asthma = asthma[asthma$year==2018,]
asthma = subset(asthma,select=-c(2,3,4))
stroke = read.csv("desktop/STATS 506/stroke.csv")
stroke = stroke[substr(stroke$end.year,1,4) %in% c("2019"),]
stroke = stroke[stroke$age == ">= 65",]
stroke = subset(stroke,select=-c(1,3,4,5,6))
df_merge = merge(uhi,climate,by="county_fips")
df_merge = merge(df_merge,insurance,by="county_fips")
df_merge = merge(df_merge,asthma,by="county_fips")
df_merge = merge(df_merge,stroke,by="county_fips")
df_merge = na.omit(df_merge)
df_merge = df_merge[!duplicated(df_merge[,1]),]
df_merge = subset(df_merge,select=-c(7,8))
# population over 65 years old
x1 = df_merge$su_daytime
x2 = df_merge$su_nighttime
x3 = df_merge$win_daytime
x4 = df_merge$win_nighttime
x5 = df_merge$mean_2m_air_temperature
x6 = df_merge$Insured...
y1 = df_merge$asthma
y2 = df_merge$stroke
fit_asthma1 <- lm(df_merge,formula = y2~x1+x2+x5+x6)
summary(fit_asthma1)
df1 <- data.frame(x1,x2,x3,x4,x5,x6,y2)
require(R2jags)
require(MASS)
require(coda)
set.seed(656)
N = length(y1)
list.data = list("x1","x2","x5","x6","y2","N")
zero = c(0,0,0,0,0)
Sigma = diag(100,5,5)
initial.parms = function() {
  list("beta"=mvrnorm(1,zero,Sigma),"tau"=rgamma(1,0.1,0.1))
}

# parameters to save
save.parms = c("beta","tau")
model = function()
{
  for (i in 1:N) {
    mu[i] <- beta[1] + x1[i]*beta[2] 
    + x2[i]*beta[3] + x5[i]*beta[4] + x6[i]*beta[5] #expected value for subject i
    y2[i] ~ dnorm(mu[i],tau)  # data distribution
    # nu <- beta[1] + 0.1*beta[2] + 0.3*beta[3] + -0.2*beta[4] + 0.4*beta[5] + 0.6*beta[6] + 0.2*beta[7]
    # y ~dnorm(nu,tau)
  }
  beta[1] ~ dunif(-1e6,1e6)   # priors (jags does not allow a flat prior or Gamma(0,0)
  beta[2] ~ dunif(-1e6,1e6)   # these are close to improper priors
  beta[3] ~ dunif(-1e6,1e6)
  beta[4] ~ dunif(-1e6,1e6)
  beta[5] ~ dunif(-1e6,1e6)
  tau ~ dgamma(1e-6,1e-6)
}
VO2.out = jags(data=list.data,parameters.to.save=save.parms,inits=initial.parms,model.file=model,
               n.chains=3,n.iter=100000,n.burnin=50000,n.thin=10)

print(VO2.out)
VO2.mcmc.list=as.mcmc(VO2.out)
attach.jags(VO2.out)

require(MCMCvis)
data(VO2.out)
MCMCplot(VO2.out, 
         params = c('beta[2]','beta[3]','beta[4]','beta[5]'),
         ISB = FALSE,
         labels = c('beta[1]','beta[2]','beta[3]','beta[4]'))
MCMCtrace(VO2.out, 
          params = c('beta[2]', 'beta[3]'),
          ind = TRUE,
          ISB = FALSE,
          pdf = FALSE,
          main_den = c("posterior density of beta[1]","posterior density of beta[2]"),
          main_tr = c("trace plot of beta[1]","trace plot of beta[2]"))






