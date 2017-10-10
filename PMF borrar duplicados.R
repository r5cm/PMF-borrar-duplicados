# Login a Salesforce
library(RForcecom)
username <- "admin@andes.org"
password <- "gfadm913XQWRiDpPU6NzJC9Cmm185FF2"
instanceURL <- "https://taroworks-8629.cloudforce.com/"
apiVersion <- "36.0"
session <- rforcecom.login(username, password, instanceURL, apiVersion)

query <- "SELECT Id FROM FMP_Diagnostics_Targets_Definition_MYE__c WHERE Last_parent_record_update__c = 0"

borrar <- rforcecom.query(session, query)

job_info <- rforcecom.createBulkJob(session, 
                                    operation='delete', 
                                    object='FMP_Diagnostics_Targets_Definition_MYE__c')

batches_info <- rforcecom.createBulkBatch(session, 
                                          jobId=job_info$id, 
                                          borrar, 
                                          multiBatch = TRUE, 
                                          batchSize = 500)

# Estado de los batches
batches_status <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.checkBatchStatus(session, 
                                                          jobId=x$jobId, 
                                                          batchId=x$id)
                         })
status <- c()
records.processed <- c()
records.failed <- c()
for(i in 1:length(batches_status)) {
      status[i] <- batches_status[[i]]$state
      records.processed[i] <- batches_status[[i]]$numberRecordsProcessed
      records.failed[i] <- batches_status[[i]]$numberRecordsFailed
}
data.frame(status, records.processed, records.failed)


# Detalles de cada batch
batches_detail <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.getBatchDetails(session, 
                                                         jobId=x$jobId, 
                                                         batchId=x$id)
                         })

# Cerrar trabajo
close_job_info <- rforcecom.closeBulkJob(session, jobId=job_info$id)
# Cerrar sesión
rforcecom.logout(session)
